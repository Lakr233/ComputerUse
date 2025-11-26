//
//  ToolInputModels.swift
//  ComputerUseKit
//
//  Strongly typed models for tool inputs with relaxed key decoding.
//

import Foundation

// MARK: - Common models

public struct ToolEmptyInput: RelaxedDecodable, Sendable {
    public init() {}
}

public struct PointerLocation: RelaxedDecodable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        x = try container.decodeDouble(for: "x")
        y = try container.decodeDouble(for: "y")
    }
}
