//
//  ToolUtils+Payloads.swift
//  ComputerUseKit
//

import Foundation

public extension ToolUtils {
    static func screenPayload(screen: ScreenContext, includeHint: Bool) -> [String: Any] {
        var payload: [String: Any] = [
            "status": "success",
            "screenshot_base64": screen.screenshotBase64,
            "screenshot_media_type": screen.screenshotMediaType,
            "pointer_location": locationPayload(screen.pointerLocation),
            "pointer_screenNumber": screen.pointerScreenNumber,
        ]
        if let app = screen.activeApplication {
            payload["active_application"] = activeAppPayload(app)
        }
        if includeHint {
            payload["hint"] = "coordinates use macOS Cocoa system (origin at bottom-left of primary screen, Y increases upward)"
        }
        return payload
    }

    static func shouldSurfaceApplication(_ app: ApplicationInfo) -> Bool {
        guard let path = app.path else { return false }

        // Some system apps are still useful (e.g., Finder). Keep those explicitly.
        let allowedBundleIds: Set<String> = [
            "com.apple.finder",
        ]
        if let bundleId = app.bundleIdentifier, allowedBundleIds.contains(bundleId) {
            return true
        }

        // General heuristics: keep user-visible apps in common app locations.
        let homeApplications = "\(FileManager.default.homeDirectoryForCurrentUser.path)/Applications/"
        let allowedPrefixes = [
            "/Applications/",
            "/System/Applications/",
            homeApplications,
        ]
        if allowedPrefixes.contains(where: { path.hasPrefix($0) }) {
            return true
        }

        return false
    }

    static func locationPayload(_ location: PointerLocation) -> [String: Double] {
        ["x": location.x, "y": location.y]
    }

    static func activeAppPayload(_ app: ActiveApplication) -> [String: Any] {
        var payload: [String: Any] = [
            "name": app.name as Any,
            "bundle_identifier": app.bundleIdentifier as Any,
            "process_id": app.processId,
            "accessibility": app.accessibility.storage,
        ]
        if let title = app.windowTitle {
            payload["window_title"] = title
        }
        if let frame = app.windowFrame {
            payload["window_frame"] = [
                "x": frame.origin.x,
                "y": frame.origin.y,
                "width": frame.size.width,
                "height": frame.size.height,
            ]
        }
        return payload
    }

    static func appPayload(_ app: ApplicationInfo) -> [String: Any] {
        var payload: [String: Any] = [
            "name": app.name as Any,
            "bundle_identifier": app.bundleIdentifier as Any,
            "path": app.path as Any,
            "running": app.running,
        ]
        if let pid = app.processId {
            payload["process_id"] = pid
        }
        return payload
    }
}
