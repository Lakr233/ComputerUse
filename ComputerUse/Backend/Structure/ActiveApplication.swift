//
//  ActiveApplication.swift
//  ComputerUseKit
//

import CoreGraphics
import Foundation

public struct ActiveApplication: Sendable {
    public let name: String?
    public let bundleIdentifier: String?
    public let processId: pid_t
    public let windowTitle: String?
    public let windowFrame: CGRect?
    public let accessibility: AnySendableDictionary
}
