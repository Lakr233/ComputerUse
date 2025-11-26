//
//  ExecutionEvent.swift
//  ComputerUseKit
//

import Foundation

public enum ExecutionEvent: Sendable {
    case willStart(ExecutionStep)
    case awaitingApproval(ExecutionStep)
    case didFinish(ExecutionStep)
    case didFail(ExecutionStep, Error)
    case completed(result: ExecutionResult?)
}
