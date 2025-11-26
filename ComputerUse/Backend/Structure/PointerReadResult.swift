//
//  PointerReadResult.swift
//  ComputerUseKit
//

import Foundation

public struct PointerReadResult: Sendable {
    public let location: PointerLocation
    public let screenNumber: String
    public let pointerStatus: [String: String]
}
