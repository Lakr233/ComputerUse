//
//  AnySendableDictionary.swift
//  ComputerUseKit
//

import Foundation

/// Light wrapper to allow sending heterogenous dictionaries across concurrency domains.
public struct AnySendableDictionary: @unchecked Sendable {
    public let storage: [String: Any]
    public init(_ storage: [String: Any]) {
        self.storage = storage
    }
}
