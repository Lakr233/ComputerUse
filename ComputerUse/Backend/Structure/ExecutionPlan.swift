//
//  ExecutionPlan.swift
//  ComputerUseKit
//

import Foundation

public struct ExecutionPlan: Sendable {
    public let toolName: String
    public let steps: [ExecutionStep]

    public init(toolName: String, steps: [ExecutionStep]) {
        self.toolName = toolName
        self.steps = steps
    }
}
