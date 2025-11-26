//
//  ToolExecutionError.swift
//  ComputerUseKit
//

import Foundation

public enum ToolExecutionError: Error {
    case unknownTool
    case missingScreen
    case accessibilityPermissionDenied
    case screenRecordingPermissionDenied
    case applicationNotFound
    case keyMappingFailed(String)
    case invalidOperation(String)
}
