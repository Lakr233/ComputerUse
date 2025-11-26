//
//  ScreenTools+Definitions.swift
//  ComputerUseKit
//

import ChatClientKit
import Foundation

extension ScreenTools {
    // MARK: SCREEN

    /*
     input: {}
     output: {
        "status": "success",
        "hint": "coordinates use macOS Cocoa system (origin at bottom-left, Y increases upward)",
        "screenshot_base64": "xxxxxx",
        "pointer_location": {"x":100,"y":200},
        "pointer_screenNumber": "xxx",
        "active_application": {
            "name": "App Name",
            "bundle_identifier": "com.example.app",
            "process_id": 12345
            "window_title": "Main Window"
            "window_frame": {"x":0,"y":0,"width":800,"height":600}
            "accessibility": { }
        }
     }
     */
    static let screenReadContentTool: ChatRequestBody.Tool = .function(
        name: "computer_use_screen_context_capture",
        description: """
        Capture screenshot, pointer location, and activated application details.
        """,
        parameters: [
            "type": "object",
            "properties": [:],
            "additionalProperties": false,
        ],
        strict: nil,
    )

    /*
     input: {}
     output: {
        "status": "success",
        "applications": [
            {
                "name": "Safari",
                "bundle_identifier": "com.apple.Safari",
                "path": "/Applications/Safari.app",
                "running": true,
                "process_id": 123
            }
        ]
     }
     */
    static let applicationReadListTool: ChatRequestBody.Tool = .function(
        name: "computer_use_applications",
        description: """
        List currently running user-facing applications and metadata. Background services and system daemons are automatically filtered out.
        """,
        parameters: [
            "type": "object",
            "properties": [:],
            "additionalProperties": false,
        ],
        strict: nil,
    )

    /*
     input: {"bundle_identifier": "com.apple.Safari"} | {"name": "Safari"} | {"path": "/Applications/Safari.app"}
     output: {
        "status": "success",
        "hint": "opens/focuses the app and returns the latest screen context to avoid another call",
        "screen": {
            "screenshot_base64": "xxxxxx",
            "pointer_location": {"x":100,"y":200},
            "pointer_screenNumber": "xxx",
            "active_application": {
                "name": "App Name",
                "bundle_identifier": "com.example.app",
                "process_id": 12345,
                "window_title": "Main Window",
                "window_frame": {"x":0,"y":0,"width":800,"height":600},
                "accessibility": { }
            }
        }
     }
     */
    static let applicationExecuteOpenTool: ChatRequestBody.Tool = .function(
        name: "computer_use_applications_open",
        description: """
        Open or focus an application by bundle identifier, name, or path, then immediately return screen context (screenshot, pointer, active app) to save an extra tool call.
        Provide at least one of: bundle_identifier | name | path.
        """,
        parameters: [
            "type": "object",
            "properties": [
                "bundle_identifier": [
                    "type": "string",
                ],
                "name": [
                    "type": "string",
                ],
                "path": [
                    "type": "string",
                ],
            ],
            "additionalProperties": false,
        ],
        strict: nil,
    )

    /*
     input: {"bundle_identifier": "com.apple.Safari", "force": true} | {"name": "Safari"} | {"path": "/Applications/Safari.app"}
     output: {"status": "success", "hint": "terminates the app; if force is true, uses force-quit semantics"}
     */
    static let applicationExecuteTerminateTool: ChatRequestBody.Tool = .function(
        name: "computer_use_applications_terminate",
        description: """
        Terminate an application by bundle identifier, name, or path. Optional `force` flag performs a force quit when true.
        Provide at least one of: bundle_identifier | name | path.
        """,
        parameters: [
            "type": "object",
            "properties": [
                "bundle_identifier": [
                    "type": "string",
                ],
                "name": [
                    "type": "string",
                ],
                "path": [
                    "type": "string",
                ],
                "force": [
                    "type": "boolean",
                ],
            ],
            "additionalProperties": false,
        ],
        strict: nil,
    )
}
