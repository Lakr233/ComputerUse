//
//  PointerServiceTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Foundation
import Testing

@Suite("PointerService Tests", .serialized)
struct PointerServiceTests {
    @MainActor
    private func getPointerViewModel() -> PointerViewModel? {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
              let viewModel = appDelegate.pointerViewModel
        else {
            return nil
        }
        return viewModel
    }

    @Test("Read pointer location")
    @MainActor
    func testReadPointer() async throws {
        guard let viewModel = getPointerViewModel() else {
            Issue.record("AppDelegate pointerViewModel not available")
            return
        }

        let screen = viewModel.screen

        try await TestHelpers.withInputTestWindow(screen: screen) { _ in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = PointerService(viewModel: viewModel)

            let result = try await service.readPointer()

            // Verify result has valid location
            #expect(result.location.x >= 0)
            #expect(result.location.y >= 0)
            #expect(!result.screenNumber.isEmpty)
        }
    }

    @Test("Perform move event")
    @MainActor
    func performMove() async throws {
        guard let viewModel = getPointerViewModel() else {
            Issue.record("AppDelegate pointerViewModel not available")
            return
        }

        let screen = viewModel.screen

        try await TestHelpers.withInputTestWindow(screen: screen) { _ in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = PointerService(viewModel: viewModel)

            let screenFrame = screen.frame
            let centerX = screenFrame.origin.x + screenFrame.width / 2
            let centerY = screenFrame.origin.y + screenFrame.height / 2

            let event = PointerEvent(
                eventType: .move,
                location: PointerLocation(x: centerX, y: centerY),
                screenNumber: nil,
                durationMs: 100,
                clickType: nil,
                clickCount: nil,
                gapMs: nil,
                deltaX: nil,
                deltaY: nil,
            )

            try await service.perform(event: event)

            // Verify pointer moved (read it back)
            let result = try await service.readPointer()
            let distance = sqrt(
                pow(result.location.x - centerX, 2) + pow(result.location.y - centerY, 2),
            )
            // Allow some tolerance for pointer movement
            #expect(distance < 50)
        }
    }

    @Test("Perform click event")
    @MainActor
    func performClick() async throws {
        guard let viewModel = getPointerViewModel() else {
            Issue.record("AppDelegate pointerViewModel not available")
            return
        }

        let screen = viewModel.screen

        var clickReceived = false

        try await TestHelpers.withInputTestWindow(
            screen: screen,
            onKeyReceived: { _ in
                clickReceived = true
            },
        ) { _ in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = PointerService(viewModel: viewModel)

            let screenFrame = screen.frame
            let centerX = screenFrame.origin.x + screenFrame.width / 2
            let centerY = screenFrame.origin.y + screenFrame.height / 2

            // Move to center first
            let moveEvent = PointerEvent(
                eventType: .move,
                location: PointerLocation(x: centerX, y: centerY),
                screenNumber: nil,
                durationMs: 100,
                clickType: nil,
                clickCount: nil,
                gapMs: nil,
                deltaX: nil,
                deltaY: nil,
            )
            try await service.perform(event: moveEvent)

            // Then click
            let clickEvent = PointerEvent(
                eventType: .click,
                location: nil,
                screenNumber: nil,
                durationMs: nil,
                clickType: .left,
                clickCount: 1,
                gapMs: 10,
                deltaX: nil,
                deltaY: nil,
            )
            try await service.perform(event: clickEvent)

            // Wait a bit for click to register
            let startTime = Date()
            while !clickReceived, Date().timeIntervalSince(startTime) < 2.0 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
        }
    }
}
