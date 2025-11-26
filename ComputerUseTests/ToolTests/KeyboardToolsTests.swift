//
//  KeyboardToolsTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Foundation
import Testing

@Suite("KeyboardTools Tests", .serialized)
struct KeyboardToolsTests {
    @Test("Keyboard execute sequence tool definition")
    func keyboardExecuteSequenceDefinition() {
        let tool = KeyboardTools.keyboardExecuteSequence
        #expect(tool.name == "computer_use_keyboard")
    }

    @Test("Keyboard execute input tool definition")
    func keyboardExecuteInputDefinition() {
        let tool = KeyboardTools.keyboardExecuteInput
        #expect(tool.name == "computer_use_keyboard_text")
    }
}
