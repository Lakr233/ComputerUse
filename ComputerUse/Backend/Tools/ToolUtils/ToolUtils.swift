//
//  ToolUtils.swift
//  ComputerUseKit
//
//  Shared helpers for building tool response payloads.
//

import ChatClientKit
import Foundation

public enum ToolUtils {
    public static func buildPayload(for toolName: String, result: ExecutionResult?) throws -> [String: Any] {
        switch toolName {
        case ScreenTools.screenReadContent.name:
            guard let screen = result?.screenContext else {
                throw ToolExecutionError.invalidOperation("Missing screen context")
            }
            return screenPayload(screen: screen, includeHint: true)
        case ScreenTools.applicationReadList.name:
            let apps = result?.applications ?? []
            let filtered = apps.filter(shouldSurfaceApplication)
            return [
                "status": "success",
                "applications": filtered.map(appPayload),
            ]
        case ScreenTools.applicationExecuteOpen.name:
            guard let screen = result?.screenContext else {
                throw ToolExecutionError.invalidOperation("Missing screen context after opening app")
            }
            return [
                "status": "success",
                "hint": "application opened/focused, returning latest screen context",
                "screen": screenPayload(screen: screen, includeHint: false),
            ]
        case ScreenTools.applicationExecuteTerminate.name:
            return [
                "status": "success",
                "hint": "application terminated",
            ]
        case PointerTools.pointerReadLocation.name:
            guard let pointer = result?.pointerInfo else {
                throw ToolExecutionError.invalidOperation("Missing pointer info")
            }
            return [
                "status": "success",
                "location": locationPayload(pointer.location),
                "screenNumber": pointer.screenNumber,
                "pointer_status": pointer.pointerStatus,
            ]
        case PointerTools.pointerExecuteSequence.name,
             KeyboardTools.keyboardExecuteSequence.name,
             KeyboardTools.keyboardExecuteInput.name:
            return ["status": "success"]
        default:
            throw ToolExecutionError.unknownTool
        }
    }
}
