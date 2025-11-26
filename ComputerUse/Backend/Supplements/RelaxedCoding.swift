//
//  RelaxedCoding.swift
//  ComputerUseKit
//
//  Relaxed decoding helpers for flexible JSON key matching.
//

import Foundation

// MARK: - Relaxed decoding helpers

public enum RelaxedCoding {
    public static func normalize(_ raw: String) -> String {
        raw.replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
}

public struct RelaxedCodingKey: CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    public init?(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }
}

public struct RelaxedContainer {
    public let container: KeyedDecodingContainer<RelaxedCodingKey>

    public init(container: KeyedDecodingContainer<RelaxedCodingKey>) {
        self.container = container
    }

    public func key(for name: String) -> RelaxedCodingKey? {
        let target = RelaxedCoding.normalize(name)
        return container.allKeys.first { RelaxedCoding.normalize($0.stringValue) == target }
    }

    public func decodeString(for name: String) throws -> String {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        return try container.decode(String.self, forKey: key)
    }

    public func decodeOptionalString(for name: String) -> String? {
        guard let key = key(for: name) else { return nil }
        return try? container.decode(String.self, forKey: key)
    }

    public func decodeBool(for name: String) throws -> Bool {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        return try container.decode(Bool.self, forKey: key)
    }

    public func decodeOptionalBool(for name: String) -> Bool? {
        guard let key = key(for: name) else { return nil }
        return try? container.decode(Bool.self, forKey: key)
    }

    public func decodeDouble(for name: String) throws -> Double {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }
        throw DecodingError.typeMismatch(
            Double.self,
            .init(codingPath: container.codingPath + [key], debugDescription: "Expected number for \(name)"),
        )
    }

    public func decodeOptionalDouble(for name: String) -> Double? {
        guard let key = key(for: name) else { return nil }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }
        return nil
    }

    public func nestedContainer(for name: String) throws -> RelaxedContainer {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        let nested = try container.nestedContainer(keyedBy: RelaxedCodingKey.self, forKey: key)
        return RelaxedContainer(container: nested)
    }

    public func nestedUnkeyedContainer(for name: String) throws -> UnkeyedDecodingContainer {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        return try container.nestedUnkeyedContainer(forKey: key)
    }

    public func decodeObject<T: Decodable>(_: T.Type, for name: String) throws -> T {
        guard let key = key(for: name) else {
            throw DecodingError.keyNotFound(
                RelaxedCodingKey(stringValue: name)!,
                .init(codingPath: container.codingPath, debugDescription: "Missing key \(name)"),
            )
        }
        let decoder = try container.superDecoder(forKey: key)
        return try T(from: decoder)
    }

    public func decodeOptionalObject<T: Decodable>(_: T.Type, for name: String) -> T? {
        guard let key = key(for: name) else { return nil }
        guard let decoder = try? container.superDecoder(forKey: key) else { return nil }
        return try? T(from: decoder)
    }
}

public extension Decoder {
    func relaxedContainer() throws -> RelaxedContainer {
        let container = try container(keyedBy: RelaxedCodingKey.self)
        return RelaxedContainer(container: container)
    }
}

public protocol RelaxedDecodable: Decodable {
    static func parse(_ data: Data) throws -> Self
}

public extension RelaxedDecodable {
    static func parse(_ data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
