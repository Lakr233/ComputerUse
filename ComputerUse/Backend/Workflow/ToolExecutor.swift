//
//  ToolExecutor.swift
//  ComputerUse
//
//  Created by GPT-5 Codex on 16/03/2026.
//

import AppKit
import ChatClientKit
import Foundation
import os

extension Function {
    var rawArgumentsText: String {
        let trimmed = argumentsRaw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty {
            return trimmed
        }

        if let arguments,
           JSONSerialization.isValidJSONObject(arguments),
           let data = try? JSONSerialization.data(withJSONObject: arguments, options: [])
        {
            return String(data: data, encoding: .utf8) ?? "{}"
        }

        return "{}"
    }
}

let workflowLogger = Logger(subsystem: "wiki.qaq.logger", category: "workflow")

@MainActor
final class ToolExecutor {
    private weak var workflow: Workflow?
    private let pointerService: PointerService
    private let screenService: ScreenService
    private let applicationService = ApplicationService()
    private let keyboardService = KeyboardService()

    init(viewModel: PointerViewModel, workflow: Workflow? = nil) {
        self.workflow = workflow
        pointerService = PointerService(viewModel: viewModel)
        screenService = ScreenService(pointerService: pointerService)
    }

    func execute(call: ToolCall) async -> [ChatRequestBody.Message] {
        let arguments = call.function.rawArgumentsText
        let payload: [String: Any]
        workflowLogger.info("tool call start: \(call.function.name, privacy: .public) input: \(arguments, privacy: .public)")

        do {
            payload = try await perform(toolName: call.function.name, arguments: arguments)
        } catch {
            payload = failurePayload(for: error, toolName: call.function.name)
        }

        if let summary = toolSummary(for: call.function.name, arguments: arguments) {
            workflowLogger.info("tool summary: \(summary, privacy: .public)")
            workflow?.title = summary
        }

        let extraction = extractScreenshots(from: payload)
        var cleanedPayload = extraction.cleanedPayload
        if !extraction.images.isEmpty {
            cleanedPayload["screenshot_images"] = extraction.images.count
            cleanedPayload["screenshot_note"] = "screenshots moved to user image attachments"
        }
        let content = jsonString(from: cleanedPayload)

        workflowLogger.info(
            "tool call done: \(call.function.name, privacy: .public) outputLength: \(content.count) output: \(content, privacy: .public)",
        )

        var messages: [ChatRequestBody.Message] = [
            .tool(content: .text(content), toolCallID: call.id),
        ]

        if !extraction.images.isEmpty {
            let parts = buildScreenshotParts(images: extraction.images, toolName: call.function.name)
            if !parts.isEmpty {
                workflowLogger.info(
                    "tool call user message: forwarding \(extraction.images.count) screenshots for \(call.function.name, privacy: .public)",
                )
                messages.append(.user(
                    content: .parts(parts),
                    name: "tool_screenshot",
                ))
            }
        }

        return messages
    }
}

@MainActor
extension ToolExecutor {
    func perform(toolName: String, arguments: String) async throws -> [String: Any] {
        switch toolName {
        case ScreenTools.screenReadContent.name:
            _ = try decodeInput(ToolEmptyInput.self, from: arguments)
            let context = try await screenService.captureScreenContext()
            return try ToolUtils.buildPayload(
                for: toolName,
                result: .init(screenContext: context),
            )
        case ScreenTools.applicationReadList.name:
            _ = try decodeInput(ToolEmptyInput.self, from: arguments)
            let applications = applicationService.listRunningApps()
            return try ToolUtils.buildPayload(
                for: toolName,
                result: .init(applications: applications),
            )
        case ScreenTools.applicationExecuteOpen.name:
            let input = try decodeInput(ApplicationOpenInput.self, from: arguments)
            try await applicationService.open(input)
            let context = try await screenService.captureScreenContext()
            return try ToolUtils.buildPayload(
                for: toolName,
                result: .init(screenContext: context),
            )
        case ScreenTools.applicationExecuteTerminate.name:
            let input = try decodeInput(ApplicationTerminateInput.self, from: arguments)
            try applicationService.terminate(input)
            return try ToolUtils.buildPayload(for: toolName, result: .init())
        case PointerTools.pointerReadLocation.name:
            _ = try decodeInput(PointerReadLocationInput.self, from: arguments)
            let pointer = try await pointerService.readPointer()
            return try ToolUtils.buildPayload(
                for: toolName,
                result: .init(pointerInfo: pointer),
            )
        case PointerTools.pointerExecuteSequence.name:
            let input = try decodeInput(PointerExecuteSequenceInput.self, from: arguments)
            try await perform(pointerSequence: input.sequence)
            return try ToolUtils.buildPayload(for: toolName, result: .init())
        case KeyboardTools.keyboardExecuteSequence.name:
            let input = try decodeInput(KeyboardSequenceInput.self, from: arguments)
            try await perform(keyboardSequence: input.sequence)
            return try ToolUtils.buildPayload(for: toolName, result: .init())
        case KeyboardTools.keyboardExecuteInput.name:
            let input = try decodeInput(KeyboardInputText.self, from: arguments)
            try keyboardService.perform(text: input)
            return try ToolUtils.buildPayload(for: toolName, result: .init())
        default:
            throw ToolExecutionError.unknownTool
        }
    }

    func perform(pointerSequence: [PointerEvent]) async throws {
        for event in pointerSequence {
            try Task.checkCancellation()
            try await pointerService.perform(event: event)
            try await sleep(milliseconds: event.durationMs)
            try await sleep(milliseconds: event.gapMs)
        }
    }

    func perform(keyboardSequence: [KeyboardEvent]) async throws {
        for event in keyboardSequence {
            try Task.checkCancellation()
            try await keyboardService.perform(event: event)
        }
    }

    func decodeInput<T: RelaxedDecodable>(
        _: T.Type,
        from arguments: String,
    ) throws -> T {
        let trimmed = arguments.trimmingCharacters(in: .whitespacesAndNewlines)
        let json = trimmed.isEmpty ? "{}" : trimmed
        guard let data = json.data(using: .utf8) else {
            throw ToolExecutionError.invalidOperation("Unable to decode arguments for \(T.self)")
        }
        return try T.parse(data)
    }

    func jsonString(from payload: [String: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]),
              let string = String(data: data, encoding: .utf8)
        else {
            return #"{"status":"error","message":"Unable to encode tool response"}"#
        }
        return string
    }

    func failurePayload(for error: Error, toolName: String) -> [String: Any] {
        [
            "status": "error",
            "tool": toolName,
            "message": readableMessage(for: error),
        ]
    }

    func toolSummary(for toolName: String, arguments: String) -> String? {
        switch toolName {
        case ScreenTools.screenReadContent.name:
            return "Capture screen context"
        case ScreenTools.applicationReadList.name:
            return "List running applications"
        case ScreenTools.applicationExecuteOpen.name:
            guard let input = try? decodeInput(ApplicationOpenInput.self, from: arguments) else {
                return "Open application"
            }
            let target = applicationTarget(from: input)
            return "Open \(target)"
        case ScreenTools.applicationExecuteTerminate.name:
            guard let input = try? decodeInput(ApplicationTerminateInput.self, from: arguments) else {
                return "Terminate application"
            }
            let target = applicationTarget(from: input)
            return input.force == true ? "Force terminate \(target)" : "Terminate \(target)"
        case PointerTools.pointerReadLocation.name:
            return "Read pointer location"
        case PointerTools.pointerExecuteSequence.name:
            guard let input = try? decodeInput(PointerExecuteSequenceInput.self, from: arguments) else {
                return "Run pointer sequence"
            }
            return summarizePointerSequence(input.sequence)
        case KeyboardTools.keyboardExecuteSequence.name:
            guard let input = try? decodeInput(KeyboardSequenceInput.self, from: arguments) else {
                return "Run keyboard sequence"
            }
            return summarizeKeyboardSequence(input.sequence)
        case KeyboardTools.keyboardExecuteInput.name:
            guard let input = try? decodeInput(KeyboardInputText.self, from: arguments) else {
                return "Type text"
            }
            let count = input.text.count
            return "Type \(count) character\(count == 1 ? "" : "s")"
        default:
            return nil
        }
    }

    func applicationTarget(from input: ApplicationOpenInput) -> String {
        if let bundle = input.bundleIdentifier, !bundle.isEmpty {
            return bundle
        }
        if let name = input.name, !name.isEmpty {
            return name
        }
        if let path = input.path, !path.isEmpty {
            return path
        }
        return "application"
    }

    func applicationTarget(from input: ApplicationTerminateInput) -> String {
        if let bundle = input.bundleIdentifier, !bundle.isEmpty {
            return bundle
        }
        if let name = input.name, !name.isEmpty {
            return name
        }
        if let path = input.path, !path.isEmpty {
            return path
        }
        return "application"
    }

    func summarizePointerSequence(_ events: [PointerEvent]) -> String {
        guard !events.isEmpty else { return "Run pointer sequence" }
        let summaries = events.map { pointerService.summary(for: $0) }
        let preview = summaries.prefix(4).joined(separator: " -> ")
        if summaries.count > 4 {
            return "Pointer sequence: \(preview) (+\(summaries.count - 4) more)"
        }
        return "Pointer sequence: \(preview)"
    }

    func summarizeKeyboardSequence(_ events: [KeyboardEvent]) -> String {
        guard !events.isEmpty else { return "Run keyboard sequence" }
        let summaries = events.map { keyboardService.summary(for: $0) }
        let preview = summaries.prefix(4).joined(separator: " -> ")
        if summaries.count > 4 {
            return "Keyboard sequence: \(preview) (+\(summaries.count - 4) more)"
        }
        return "Keyboard sequence: \(preview)"
    }

    func readableMessage(for error: Error) -> String {
        if let error = error as? ToolExecutionError {
            switch error {
            case .unknownTool:
                return "unknown tool requested"
            case .missingScreen:
                return "no active screen available"
            case .accessibilityPermissionDenied:
                return "missing accessibility permission"
            case .screenRecordingPermissionDenied:
                return "missing screen recording permission"
            case .applicationNotFound:
                return "target application not found"
            case let .keyMappingFailed(reason):
                return reason
            case let .invalidOperation(reason):
                return reason
            }
        }
        return error.localizedDescription
    }

    func sleep(milliseconds: Double?) async throws {
        guard let milliseconds, milliseconds > 0 else { return }
        try Task.checkCancellation()
        let nanoseconds = UInt64(milliseconds * 1_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }

    struct ExtractedImage {
        let base64: String
        let mediaType: String
    }

    func extractScreenshots(from payload: [String: Any]) -> (cleanedPayload: [String: Any], images: [ExtractedImage]) {
        var images: [ExtractedImage] = []
        let cleaned = stripScreenshots(in: payload, images: &images) as? [String: Any] ?? payload
        return (cleaned, images)
    }

    func stripScreenshots(in value: Any, images: inout [ExtractedImage]) -> Any {
        if let dictionary = value as? [String: Any] {
            var cleaned: [String: Any] = [:]
            var pendingBase64: String?
            var pendingMediaType: String?

            for (key, val) in dictionary {
                if key == "screenshot_base64", let image = val as? String {
                    pendingBase64 = image
                    continue
                }
                if key == "screenshot_media_type", let mediaType = val as? String {
                    pendingMediaType = mediaType
                    continue
                }
                cleaned[key] = stripScreenshots(in: val, images: &images)
            }

            // Add extracted image with media type
            if let base64 = pendingBase64 {
                let mediaType = pendingMediaType ?? detectMediaType(from: base64)
                images.append(ExtractedImage(base64: base64, mediaType: mediaType))
            }

            return cleaned
        }

        if let array = value as? [Any] {
            return array.map { stripScreenshots(in: $0, images: &images) }
        }

        if let string = value as? String, isBase64Image(string) {
            let mediaType = detectMediaType(from: string)
            images.append(ExtractedImage(base64: string, mediaType: mediaType))
            return "<omitted>"
        }

        return value
    }

    func detectMediaType(from base64: String) -> String {
        guard let data = Data(base64Encoded: String(base64.prefix(32)), options: [.ignoreUnknownCharacters]),
              data.count >= 3
        else {
            return "image/jpeg"
        }

        // Check magic bytes for image format
        let bytes = [UInt8](data)
        if bytes.count >= 3, bytes[0] == 0xFF, bytes[1] == 0xD8, bytes[2] == 0xFF {
            return "image/jpeg"
        }
        if bytes.count >= 8, bytes[0] == 0x89, bytes[1] == 0x50, bytes[2] == 0x4E, bytes[3] == 0x47 {
            return "image/png"
        }

        return "image/jpeg"
    }

    func buildScreenshotParts(images: [ExtractedImage], toolName: String) -> [ChatRequestBody.Message.ContentPart] {
        var parts: [ChatRequestBody.Message.ContentPart] = []
        guard !images.isEmpty else { return parts }

        parts.append(.text("Screenshot from \(toolName)"))
        for (index, image) in images.enumerated() {
            guard let url = URL(string: "data:\(image.mediaType);base64,\(image.base64)") else { continue }
            let label = images.count > 1 ? "image \(index + 1)" : "image"
            parts.append(.text(label))
            parts.append(.imageURL(url, detail: .low))
        }
        return parts
    }

    func isBase64Image(_ string: String) -> Bool {
        guard string.count > 1000,
              let data = Data(base64Encoded: string, options: [.ignoreUnknownCharacters]),
              data.count > 100
        else {
            return false
        }
        return NSImage(data: data) != nil
    }

    func buildInitialContext() async -> [ChatRequestBody.Message.ContentPart] {
        workflowLogger.info("building initial context with application list and screen capture")

        var parts: [ChatRequestBody.Message.ContentPart] = []

        let apps = applicationService.listRunningApps()
        let filtered = apps.filter(ToolUtils.shouldSurfaceApplication)
        let appList = filtered.map { app -> String in
            var parts: [String] = []
            if let name = app.name {
                parts.append(name)
            }
            if let bundleId = app.bundleIdentifier {
                parts.append("(\(bundleId))")
            }
            return parts.joined(separator: " ")
        }
        let applicationListText = "Running applications: \(appList.joined(separator: ", "))"
        parts.append(.text("[Application List]\n\(applicationListText)"))

        let toolName = ScreenTools.screenReadContent.name
        let payload: [String: Any]
        do {
            let context = try await screenService.captureScreenContext()
            payload = try ToolUtils.buildPayload(
                for: toolName,
                result: .init(screenContext: context),
            )
        } catch {
            payload = failurePayload(for: error, toolName: toolName)
        }

        let extraction = extractScreenshots(from: payload)
        var cleanedPayload = extraction.cleanedPayload
        if !extraction.images.isEmpty {
            cleanedPayload["screenshot_images"] = extraction.images.count
            cleanedPayload["screenshot_note"] = "screenshots moved to user image attachments"
        }
        let content = jsonString(from: cleanedPayload)

        parts.append(.text("[Screen Context]\n\(content)"))

        if !extraction.images.isEmpty {
            let screenshotParts = buildScreenshotParts(images: extraction.images, toolName: toolName)
            parts.append(contentsOf: screenshotParts)
        }

        workflowLogger.info("initial context built with \(parts.count) parts")

        return parts
    }
}
