//
//  ToolInputModels+Keyboard.swift
//  ComputerUseKit
//

import Foundation

// MARK: - Keyboard tools

public enum KeyboardEventType: Sendable {
    case keydown
    case keyup
    case text
    case delay

    static func from(_ raw: String) throws -> Self {
        switch RelaxedCoding.normalize(raw) {
        case "keydown": return .keydown
        case "keyup": return .keyup
        case "text": return .text
        case "delay": return .delay
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Unknown eventType \(raw)"),
            )
        }
    }
}

public struct KeyboardEvent: RelaxedDecodable, Sendable {
    public let eventType: KeyboardEventType
    public let key: String?
    public let text: String?
    public let durationMs: Double?

    public init(eventType: KeyboardEventType, key: String?, text: String?, durationMs: Double?) {
        self.eventType = eventType
        self.key = key
        self.text = text
        self.durationMs = durationMs
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        let eventTypeRaw = try container.decodeString(for: "eventType")
        let eventType = try KeyboardEventType.from(eventTypeRaw)

        switch eventType {
        case .keydown, .keyup:
            let keyValue = try container.decodeString(for: "key")
            self.init(eventType: eventType, key: keyValue, text: nil, durationMs: nil)
        case .text:
            let text = try container.decodeString(for: "text")
            self.init(eventType: eventType, key: nil, text: text, durationMs: nil)
        case .delay:
            let duration = try container.decodeDouble(for: "duration_ms")
            self.init(eventType: eventType, key: nil, text: nil, durationMs: duration)
        }
    }
}

public struct KeyboardSequenceInput: RelaxedDecodable, Sendable {
    public let sequence: [KeyboardEvent]

    public init(sequence: [KeyboardEvent]) {
        self.sequence = sequence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        var eventsContainer = try container.nestedUnkeyedContainer(for: "sequence")
        var events: [KeyboardEvent] = []
        while !eventsContainer.isAtEnd {
            let eventDecoder = try eventsContainer.superDecoder()
            let event = try KeyboardEvent(from: eventDecoder)
            events.append(event)
        }
        sequence = events
    }
}

public struct KeyboardInputText: RelaxedDecodable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        text = try container.decodeString(for: "text")
    }
}
