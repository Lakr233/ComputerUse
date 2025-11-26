//
//  KeyboardService.swift
//  ComputerUseKit
//

import ApplicationServices
import Carbon.HIToolbox.Events
import Foundation

final class KeyboardService {
    var pressedKeys = Set<CGKeyCode>()

    func summary(for event: KeyboardEvent) -> String {
        switch event.eventType {
        case .keydown: "Key down \(event.key ?? "")"
        case .keyup: "Key up \(event.key ?? "")"
        case .text: "Type text chunk"
        case .delay: "Delay \(event.durationMs ?? 0)ms"
        }
    }

    func perform(event: KeyboardEvent) async throws {
        switch event.eventType {
        case .keydown:
            let code = try keyCode(for: event.key)
            // Ignore repeated keydown for the same key to avoid extra characters being emitted.
            guard pressedKeys.insert(code).inserted else { return }
            postKeyEvent(code: code, isKeyDown: true)
        case .keyup:
            let code = try keyCode(for: event.key)
            postKeyEvent(code: code, isKeyDown: false)
            pressedKeys.remove(code)
        case .text:
            if let text = event.text {
                postUnicode(text)
            }
        case .delay:
            if let duration = event.durationMs {
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000))
            }
        }
    }

    func perform(text: KeyboardInputText) throws {
        postUnicode(text.text)
    }
}
