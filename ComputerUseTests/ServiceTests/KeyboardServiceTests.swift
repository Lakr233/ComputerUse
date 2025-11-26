//
//  KeyboardServiceTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Testing

@Suite("KeyboardService Tests", .serialized)
struct KeyboardServiceTests {
    @Test("Summary for keyboard events")
    func testSummary() {
        let service = KeyboardService()

        let keydownEvent = KeyboardEvent(
            eventType: .keydown,
            key: "a",
            text: nil,
            durationMs: nil,
        )
        let summary = service.summary(for: keydownEvent)
        #expect(summary.contains("Key down"))
        #expect(summary.contains("a"))

        let textEvent = KeyboardEvent(
            eventType: .text,
            key: nil,
            text: "hello",
            durationMs: nil,
        )
        let textSummary = service.summary(for: textEvent)
        #expect(textSummary.contains("Type text chunk"))

        let delayEvent = KeyboardEvent(
            eventType: .delay,
            key: nil,
            text: nil,
            durationMs: 100,
        )
        let delaySummary = service.summary(for: delayEvent)
        #expect(delaySummary.contains("Delay"))
        #expect(delaySummary.contains("100"))
    }

    @Test("Perform text input with test window")
    @MainActor
    func performText() async throws {
        guard let screen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        var receivedText = ""
        var textReceived = false

        try await TestHelpers.withInputTestWindow(
            screen: screen,
            onTextReceived: { text in
                receivedText = text
                textReceived = true
            },
        ) { window in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = KeyboardService()
            let input = KeyboardInputText(text: "test")

            try service.perform(text: input)

            // Wait for text to be received (with timeout)
            let startTime = Date()
            while !textReceived, Date().timeIntervalSince(startTime) < 3.0 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }

            // Verify text was actually typed
            let windowText = window.getTextFieldContent()
            #expect(windowText.contains("test") || receivedText.contains("test"))
        }
    }

    @Test("Perform keyboard event sequence with test window")
    @MainActor
    func performKeyboardEventSequence() async throws {
        guard let screen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        var receivedText = ""
        var textReceived = false

        try await TestHelpers.withInputTestWindow(
            screen: screen,
            onTextReceived: { text in
                receivedText = text
                textReceived = true
            },
        ) { window in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = KeyboardService()

            // Test typing "hello" using text event
            let textEvent = KeyboardEvent(
                eventType: .text,
                key: nil,
                text: "hello",
                durationMs: nil,
            )

            try await service.perform(event: textEvent)

            // Wait for text to be received (with timeout)
            let startTime = Date()
            while !textReceived, Date().timeIntervalSince(startTime) < 3.0 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }

            // Verify text was actually typed
            let windowText = window.getTextFieldContent()
            #expect(windowText.contains("hello") || receivedText.contains("hello"))
        }
    }

    @Test("Perform keydown and keyup events with test window")
    @MainActor
    func performKeydownKeyup() async throws {
        guard let screen = NSScreen.main else {
            Issue.record("No main screen available")
            return
        }

        var receivedText = ""
        var textReceived = false

        try await TestHelpers.withInputTestWindow(
            screen: screen,
            onTextReceived: { text in
                receivedText = text
                textReceived = true
            },
        ) { window in
            // Wait a bit for window to be ready
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            let service = KeyboardService()

            // Test typing "a" using keydown and keyup
            let keydownEvent = KeyboardEvent(
                eventType: .keydown,
                key: "a",
                text: nil,
                durationMs: nil,
            )
            let keyupEvent = KeyboardEvent(
                eventType: .keyup,
                key: "a",
                text: nil,
                durationMs: nil,
            )

            // press return key because the input method might need it
            let returnKeydownEvent = KeyboardEvent(
                eventType: .keydown,
                key: "return",
                text: nil,
                durationMs: nil,
            )
            let returnKeyupEvent = KeyboardEvent(
                eventType: .keyup,
                key: "return",
                text: nil,
                durationMs: nil,
            )

            try await service.perform(event: keydownEvent)
            try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            try await service.perform(event: keyupEvent)

            try await service.perform(event: returnKeydownEvent)
            try await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            try await service.perform(event: returnKeyupEvent)

            // Wait for text to be received (with timeout)
            let startTime = Date()
            while !textReceived, Date().timeIntervalSince(startTime) < 3.0 {
                try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }

            // Verify "a" was actually typed
            let windowText = window.getTextFieldContent()
            #expect(windowText.contains("a") || receivedText.contains("a"))
        }
    }
}
