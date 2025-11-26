//
//  DisplayServiceTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import CoreGraphics
import Testing

@Suite("DisplayService Tests", .serialized)
struct DisplayServiceTests {
    @Test("Screen number returns valid string")
    func testScreenNumber() {
        guard let mainScreen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        let service = DisplayService()
        let screenNumber = service.screenNumber(mainScreen)

        // Should return a non-empty string
        #expect(!screenNumber.isEmpty)

        // Should be numeric
        let isNumeric = Int(screenNumber) != nil
        #expect(isNumeric)
    }

    @Test("Screen for number returns correct screen")
    func screenForNumber() throws {
        guard let mainScreen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        let service = DisplayService()
        let screenNumber = ScreenSelectorCheck.screenNumber(mainScreen)
        let result = try service.screen(for: screenNumber)
        #expect(result == mainScreen)

        // Test nil returns main screen
        let mainScreenResult = try service.screen(for: nil)
        #expect(mainScreenResult == mainScreen)
    }

    @Test("Screen for invalid number falls back to main")
    func screenForInvalidNumber() throws {
        guard let mainScreen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        let service = DisplayService()
        let result = try service.screen(for: "99999")
        #expect(result == mainScreen)
    }

    @Test("Global point calculation")
    func testGlobalPoint() throws {
        guard let mainScreen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        let service = DisplayService()
        let screenNumber = ScreenSelectorCheck.screenNumber(mainScreen)

        let location = PointerLocation(x: 100, y: 200)
        let globalPoint = try service.globalPoint(for: location, on: screenNumber)

        // Global point should be within screen bounds
        let screenFrame = mainScreen.frame
        #expect(globalPoint.x >= screenFrame.minX)
        #expect(globalPoint.x <= screenFrame.maxX)
        #expect(globalPoint.y >= screenFrame.minY)
        #expect(globalPoint.y <= screenFrame.maxY)
    }
}
