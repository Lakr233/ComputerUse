//
//  ScreenServiceTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Foundation
import Testing

@Suite("ScreenService Tests", .serialized)
struct ScreenServiceTests {
    @Test("Capture screen context with test window")
    @MainActor
    func testCaptureScreenContext() async throws {
        guard let screen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        try await TestHelpers.withInputTestWindow(screen: screen) { _ in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let viewModel = PointerViewModel(screen: screen)
            let pointerService = PointerService(viewModel: viewModel)
            let screenService = ScreenService(pointerService: pointerService)

            let context = try await screenService.captureScreenContext()

            // Verify context has valid data
            #expect(!context.screenshotBase64.isEmpty)
            #expect(context.pointerLocation.x >= 0)
            #expect(context.pointerLocation.y >= 0)
            #expect(!context.pointerScreenNumber.isEmpty)
        }
    }

    @Test("Capture accessibility elements from test window")
    @MainActor
    func captureAccessibilityElements() async throws {
        guard let screen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        try await TestHelpers.withInputTestWindow(screen: screen) { window in
            // Wait for window to be ready and accessible
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

            // Ensure window is frontmost for accessibility API
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let viewModel = PointerViewModel(screen: screen)
            let pointerService = PointerService(viewModel: viewModel)
            let screenService = ScreenService(pointerService: pointerService)

            let context = try await screenService.captureScreenContext()

            // Verify active application context exists
            guard let activeApp = context.activeApplication else {
                Issue.record("No active application context found")
                return
            }

            // Verify accessibility data exists
            let accessibility = activeApp.accessibility.storage
            guard !accessibility.isEmpty else {
                Issue.record("No accessibility data found")
                return
            }

            // Verify focused element exists and has correct attributes
            guard let focusedElement = accessibility["focused_element"] as? [String: Any] else {
                Issue.record("No focused element found")
                return
            }

            // Verify focused element is the text field
            #expect(focusedElement["role"] as? String == "AXTextField", "Focused element should be a text field")
            #expect(focusedElement["identifier"] as? String == "test-text-field", "Focused element should have correct identifier")
            #expect(focusedElement["label"] != nil || focusedElement["title"] != nil, "Focused element should have label or title")
            #expect(focusedElement["frame"] != nil, "Focused element should have frame")
            #expect(focusedElement["enabled"] as? Bool == true, "Focused element should be enabled")
            #expect(focusedElement["focused"] as? Bool == true, "Focused element should be focused")

            // Verify interactive elements are collected
            if let interactiveElements = accessibility["interactive_elements"] as? [[String: Any]] {
                #expect(!interactiveElements.isEmpty, "Should have at least one interactive element")

                // Verify each interactive element has required attributes
                for element in interactiveElements {
                    #expect(element["role"] != nil, "Interactive element should have role")
                    #expect(element["frame"] != nil, "Interactive element should have frame")
                }
            }
        }
    }
}
