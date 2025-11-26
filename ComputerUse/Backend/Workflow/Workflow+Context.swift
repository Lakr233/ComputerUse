//
//  Workflow+Context.swift
//  ComputerUse
//

import AppKit
import ChatClientKit
import Foundation
import GPTEncoder
import os

extension Workflow {
    func buildMessages(for prompt: String, executor _: ToolExecutor) -> [ChatRequestBody.Message] {
        [
            .developer(content: .text(systemPrompt())),
            .developer(content: .text(runtimePrompt())),
            .user(content: .text(prompt)),
        ]
    }
}
