//
//  Workflow.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import ChatClientKit
import Combine
import Foundation
import GPTEncoder
import os

@MainActor
class Workflow: NSObject, ObservableObject {
    var isRunning: Bool { task != nil }

    @Published var title: String = ""
    @Published var editorText: String = ""
    @Published var streamText: String = ""
    @Published var task: Task<Void, Never>? = nil

    let jsonEncoder = JSONEncoder()
    let tokenEncoder = GPTEncoder()
    let pointerViewModel: PointerViewModel
    let maxToolIterations = 1024
    let maxContextTokens = 256_000
    let minTailMessages = 6
    let truncatedTextCharacterLimit = 8000

    init(pointerViewModel: PointerViewModel) {
        self.pointerViewModel = pointerViewModel
        super.init()
    }

    func submit() {
        title = editorText
        editorText = ""
        executeOnce()
    }

    func cancel() {
        task?.cancel()
    }
}
