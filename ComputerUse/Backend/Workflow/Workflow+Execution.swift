//
//  Workflow+Execution.swift
//  ComputerUse
//

import ChatClientKit
import Foundation
import os

@MainActor
extension Workflow {
    func executeOnce() {
        task?.cancel()
        waitForAllowance {
            let task = Task {
                do {
                    try await self.executeOnceAsync()
                } catch is CancellationError {
                    // No-op, user cancelled.
                } catch {
                    print("workflow execution error: \(error)")
                    await MainActor.run {
                        self.title = "Error: \(error.localizedDescription)"
                    }
                }
                await MainActor.run { self.task = nil }
            }
            self.task = task
        }
    }

    func waitForAllowance(_ completion: @escaping @MainActor () -> Void) {
        if task == nil {
            completion()
            return
        }
        Task.detached {
            while true {
                try await Task.sleep(nanoseconds: 100_000_000)
                let capture = MainActor.isolated { self.task == nil }
                if capture { break }
            }
            await MainActor.run { completion() }
        }
    }

    func executeOnceAsync() async throws {
        let prompt = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        let chatClient = makeChatClient()
        let executor = ToolExecutor(viewModel: pointerViewModel, workflow: self)

        var messages = buildMessages(for: prompt, executor: executor)

        let initialContext = await executor.buildInitialContext()
        messages.append(.user(content: .parts(initialContext)))

        var iteration = 0

        while true {
            try Task.checkCancellation()

            if let lastMessage = messages.last, case .user = lastMessage {
                // good
            } else {
                messages.append(.user(content: .text("Continue")))
            }

            let body = ChatRequestBody(
                messages: messages,
                temperature: 0.2,
                tools: Tools.all,
            )

            let response = try await chatClient.streamingChatCompletionRequest(body: body)

            var reasoning = ""
            var content = ""
            var tools: [ToolCallRequest] = []
            var details: [ReasoningDetail] = []

            for try await chunk in response {
                try Task.checkCancellation()
                switch chunk {
                case let .chatCompletionChunk(chunk):
                    for choice in chunk.choices {
                        if let delta = choice.delta.reasoningContent, !delta.isEmpty {
                            reasoning += delta
                            streamText = reasoning
                        }
                        if let delta = choice.delta.content {
                            content += delta
                            streamText = content
                        }
                        if let delta = choice.delta.reasoningDetails {
                            details.append(contentsOf: delta)
                        }
                    }

                case let .tool(call):
                    tools.append(call)
                    logger.info("Collected tool call: \(call.name) with args: \(call.args)")
                }
            }
            try Task.checkCancellation()

            logger.info("AI Response received. Reasoning: \(reasoning), Content: \(content), Tool calls: \(tools.count)")

            messages.append(.assistant(
                content: content.isEmpty ? nil : .text(content),
                toolCalls: tools.isEmpty ? nil : tools.map { call in
                    .init(
                        id: call.id,
                        function: .init(name: call.name, arguments: call.args),
                    )
                },
                reasoning: reasoning.isEmpty ? nil : reasoning,
                reasoningDetails: details.isEmpty ? nil : details,
            ))

            if tools.isEmpty {
                if streamText.isEmpty {
                    streamText = "AI decided not to use any tool, conversation ended."
                }
                break
            }

            guard iteration < maxToolIterations else {
                throw WorkflowError.toolIterationLimit
            }
            iteration += 1

            for call in tools {
                try Task.checkCancellation()
                let result = await executor.execute(call: .init(
                    id: call.id,
                    functionName: call.name,
                    argumentsJSON: call.args,
                ))
                messages.append(contentsOf: result)
            }
        }
    }

    func makeChatClient() -> ChatService {
        RemoteCompletionsChatClient(
            model: ModelConfigurationCheck.selectedModel,
            baseURL: "https://openrouter.ai",
            path: "/api/v1/chat/completions",
            apiKey: ModelConfigurationCheck.openRouterToken,
            additionalBodyField: [
                "provider": [
                    "data_collection": "deny",
                    "zdr": true,
                ],
                "reasoning": [
                    "enabled": true,
                    "max_tokens": 512,
                ],
            ],
        )
    }
}
