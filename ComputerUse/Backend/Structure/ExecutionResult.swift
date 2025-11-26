//
//  ExecutionResult.swift
//  ComputerUseKit
//

import Foundation

public struct ExecutionResult: Sendable {
    public var screenContext: ScreenContext?
    public var applications: [ApplicationInfo]?
    public var pointerInfo: PointerReadResult?

    public init(
        screenContext: ScreenContext? = nil,
        applications: [ApplicationInfo]? = nil,
        pointerInfo: PointerReadResult? = nil,
    ) {
        self.screenContext = screenContext
        self.applications = applications
        self.pointerInfo = pointerInfo
    }
}
