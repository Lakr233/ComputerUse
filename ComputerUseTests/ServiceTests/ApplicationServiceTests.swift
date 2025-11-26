//
//  ApplicationServiceTests.swift
//  ComputerUseTests
//

import AppKit
@testable import ComputerUse
import Testing

@Suite("ApplicationService Tests", .serialized)
struct ApplicationServiceTests {
    @Test("List running apps returns valid application info")
    func testListRunningApps() {
        let service = ApplicationService()
        let apps = service.listRunningApps()

        // Should return some apps
        #expect(!apps.isEmpty)

        // Should not contain apps from private frameworks
        let privateFrameworkApps = apps.filter { app in
            guard let path = app.path else { return false }
            return path.hasPrefix("/System/Library/PrivateFrameworks/")
        }
        #expect(privateFrameworkApps.isEmpty)

        // All returned apps should have running = true
        let allRunning = apps.allSatisfy(\.running)
        #expect(allRunning)

        // Verify app structure - at least one of name, bundleIdentifier, or path should be present
        guard let firstApp = apps.first else {
            Issue.record("No apps found")
            return
        }
        let hasInfo = firstApp.name != nil || firstApp.bundleIdentifier != nil || firstApp.path != nil
        #expect(hasInfo)
    }

    @Test("Open Safari by bundle identifier")
    func openSafariByBundleIdentifier() async throws {
        let service = ApplicationService()
        let input = ApplicationOpenInput(
            bundleIdentifier: "com.apple.Safari",
            name: nil,
            path: nil,
        )

        // Open Safari
        try await service.open(input)

        // Wait a bit for Safari to launch
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify Safari is running
        let runningApps = service.listRunningApps()
        let safariRunning = runningApps.contains { app in
            app.bundleIdentifier == "com.apple.Safari"
        }
        #expect(safariRunning)
    }

    @Test("Open Safari by name")
    func openSafariByName() async throws {
        let service = ApplicationService()
        let input = ApplicationOpenInput(
            bundleIdentifier: nil,
            name: "Safari",
            path: nil,
        )

        // Open Safari
        try await service.open(input)

        // Wait a bit for Safari to launch
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify Safari is running
        let runningApps = service.listRunningApps()
        let safariRunning = runningApps.contains { app in
            app.name == "Safari" || app.bundleIdentifier == "com.apple.Safari"
        }
        #expect(safariRunning)
    }

    @Test("Open and terminate Safari")
    func openAndTerminateSafari() async throws {
        let service = ApplicationService()

        // Open Safari
        let openInput = ApplicationOpenInput(
            bundleIdentifier: "com.apple.Safari",
            name: nil,
            path: nil,
        )
        try await service.open(openInput)
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Verify Safari is running
        var runningApps = service.listRunningApps()
        var safariRunning = runningApps.contains { app in
            app.bundleIdentifier == "com.apple.Safari"
        }
        #expect(safariRunning)

        // Terminate Safari
        let terminateInput = ApplicationTerminateInput(
            bundleIdentifier: "com.apple.Safari",
            name: nil,
            path: nil,
            force: false,
        )
        try service.terminate(terminateInput)

        // Wait for Safari to terminate
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

        // Verify Safari is no longer running
        runningApps = service.listRunningApps()
        safariRunning = runningApps.contains { app in
            app.bundleIdentifier == "com.apple.Safari"
        }
        #expect(!safariRunning)
    }
}
