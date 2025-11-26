//
//  ToolInputModels+Screen.swift
//  ComputerUseKit
//

import Foundation

// MARK: - Screen tools

public typealias ScreenReadContentInput = ToolEmptyInput
public typealias ApplicationReadListInput = ToolEmptyInput

public struct ApplicationOpenInput: RelaxedDecodable, Sendable {
    public let bundleIdentifier: String?
    public let name: String?
    public let path: String?

    public init(bundleIdentifier: String?, name: String?, path: String?) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.path = path
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        let bundleIdentifier = container.decodeOptionalString(for: "bundle_identifier")
        let name = container.decodeOptionalString(for: "name")
        let path = container.decodeOptionalString(for: "path")

        guard bundleIdentifier != nil || name != nil || path != nil else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: container.container.codingPath, debugDescription: "Provide at least one of bundle_identifier, name, or path."),
            )
        }

        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.path = path
    }
}

public struct ApplicationTerminateInput: RelaxedDecodable, Sendable {
    public let bundleIdentifier: String?
    public let name: String?
    public let path: String?
    public let force: Bool?

    public init(bundleIdentifier: String?, name: String?, path: String?, force: Bool?) {
        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.path = path
        self.force = force
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        let bundleIdentifier = container.decodeOptionalString(for: "bundle_identifier")
        let name = container.decodeOptionalString(for: "name")
        let path = container.decodeOptionalString(for: "path")
        let force = container.decodeOptionalBool(for: "force")

        guard bundleIdentifier != nil || name != nil || path != nil else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: container.container.codingPath, debugDescription: "Provide at least one of bundle_identifier, name, or path."),
            )
        }

        self.bundleIdentifier = bundleIdentifier
        self.name = name
        self.path = path
        self.force = force
    }
}
