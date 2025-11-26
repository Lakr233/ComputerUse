//
//  TestHelpers.swift
//  ComputerUseTests
//
//  Shared test utilities and setup.
//

import AppKit
import Foundation
import Testing

@MainActor
enum TestHelpers {
    static func withInputTestWindow<T>(
        screen: NSScreen? = nil,
        onTextReceived: ((String) -> Void)? = nil,
        onKeyReceived: ((String) -> Void)? = nil,
        timeout: TimeInterval = 30,
        _ block: (TestWindow) async throws -> T,
    ) async rethrows -> T {
        let targetScreen = screen ?? NSScreen.main ?? NSScreen.screens.first!
        let window = TestWindow(
            screen: targetScreen,
            onTextReceived: onTextReceived,
            onKeyReceived: onKeyReceived,
            autoCloseAfter: nil,
        )

        // Auto-close task for timeout
        let timeoutTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            if window.isVisible {
                window.close()
                Issue.record("Test window auto-closed after \(timeout) seconds timeout.")
            }
        }

        defer {
            timeoutTask.cancel()
            window.close()
        }

        return try await block(window)
    }
}
