//
//  ApplicationInfo.swift
//  ComputerUseKit
//

import Foundation

public struct ApplicationInfo: Sendable {
    public let name: String?
    public let bundleIdentifier: String?
    public let path: String?
    public let running: Bool
    public let processId: pid_t?
}
