//
//  PointerToolsTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Foundation
import Testing

@Suite("PointerTools Tests", .serialized)
struct PointerToolsTests {
    @Test("Pointer read location tool definition")
    func pointerReadLocationDefinition() {
        let tool = PointerTools.pointerReadLocation
        #expect(tool.name == "computer_use_pointer_location")
    }

    @Test("Pointer execute sequence tool definition")
    func pointerExecuteSequenceDefinition() {
        let tool = PointerTools.pointerExecuteSequence
        #expect(tool.name == "computer_use_pointer")
    }
}
