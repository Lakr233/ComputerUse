//
//  ScreenToolsTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Foundation
import Testing

@Suite("ScreenTools Tests", .serialized)
struct ScreenToolsTests {
    @Test("Screen read content tool definition")
    func screenReadContentDefinition() {
        let tool = ScreenTools.screenReadContent
        #expect(tool.name == "computer_use_screen_context_capture")
    }

    @Test("Application read list tool definition")
    func applicationReadListDefinition() {
        let tool = ScreenTools.applicationReadList
        #expect(tool.name == "computer_use_applications")
    }

    @Test("Application execute open tool definition")
    func applicationExecuteOpenDefinition() {
        let tool = ScreenTools.applicationExecuteOpen
        #expect(tool.name == "computer_use_applications_open")
    }

    @Test("Application execute terminate tool definition")
    func applicationExecuteTerminateDefinition() {
        let tool = ScreenTools.applicationExecuteTerminate
        #expect(tool.name == "computer_use_applications_terminate")
    }
}
