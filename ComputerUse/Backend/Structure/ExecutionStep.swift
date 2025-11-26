//
//  ExecutionStep.swift
//  ComputerUseKit
//

import CoreGraphics
import Foundation

public struct ExecutionStep: Identifiable, Sendable {
    public enum Kind: Sendable {
        case keyboard(KeyboardEvent)
        case keyboardText(KeyboardInputText)
        case pointer(PointerEvent)
        case pointerRead
        case screenRead
        case appList
        case appOpen(ApplicationOpenInput)
        case appTerminate(ApplicationTerminateInput)
    }

    public let id: UUID
    public let kind: Kind
    public let summary: String
}
