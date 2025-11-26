//
//  ToolInputModels+Pointer.swift
//  ComputerUseKit
//

import Foundation

// MARK: - Pointer tools

public typealias PointerReadLocationInput = ToolEmptyInput

public enum PointerClickType: String, Sendable {
    case left
    case right
    case middle

    static func from(_ raw: String) throws -> Self {
        switch RelaxedCoding.normalize(raw) {
        case "left": return .left
        case "right": return .right
        case "middle": return .middle
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Unknown clickType \(raw)"),
            )
        }
    }
}

public enum PointerEventType: Sendable {
    case move
    case click
    case down
    case up
    case scroll

    static func from(_ raw: String) throws -> Self {
        switch RelaxedCoding.normalize(raw) {
        case "move": return .move
        case "click": return .click
        case "down": return .down
        case "up": return .up
        case "scroll": return .scroll
        default:
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Unknown eventType \(raw)"),
            )
        }
    }
}

public struct PointerEvent: RelaxedDecodable, Sendable {
    public let eventType: PointerEventType
    public let location: PointerLocation?
    public let screenNumber: String?
    public let durationMs: Double?
    public let clickType: PointerClickType?
    public let clickCount: Int?
    public let gapMs: Double?
    public let deltaX: Double?
    public let deltaY: Double?

    public init(
        eventType: PointerEventType,
        location: PointerLocation?,
        screenNumber: String?,
        durationMs: Double?,
        clickType: PointerClickType?,
        clickCount: Int?,
        gapMs: Double?,
        deltaX: Double?,
        deltaY: Double?,
    ) {
        self.eventType = eventType
        self.location = location
        self.screenNumber = screenNumber
        self.durationMs = durationMs
        self.clickType = clickType
        self.clickCount = clickCount
        self.gapMs = gapMs
        self.deltaX = deltaX
        self.deltaY = deltaY
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        let eventTypeRaw = try container.decodeString(for: "eventType")
        let eventType = try PointerEventType.from(eventTypeRaw)

        switch eventType {
        case .move:
            let location = try container.decodeObject(PointerLocation.self, for: "location")
            let screenNumber = container.decodeOptionalString(for: "screenNumber")
            let durationMs = container.decodeOptionalDouble(for: "duration_ms")
            self.init(
                eventType: eventType,
                location: location,
                screenNumber: screenNumber,
                durationMs: durationMs,
                clickType: nil,
                clickCount: nil,
                gapMs: nil,
                deltaX: nil,
                deltaY: nil,
            )
        case .click:
            let clickTypeRaw = try container.decodeString(for: "clickType")
            let clickType = try PointerClickType.from(clickTypeRaw)
            let clickCount = container.decodeOptionalDouble(for: "clickCount").map { Int($0) }
            let gapMs = container.decodeOptionalDouble(for: "gap_ms")
            self.init(
                eventType: eventType,
                location: nil,
                screenNumber: nil,
                durationMs: nil,
                clickType: clickType,
                clickCount: clickCount,
                gapMs: gapMs,
                deltaX: nil,
                deltaY: nil,
            )
        case .down, .up:
            let clickTypeRaw = try container.decodeString(for: "clickType")
            let clickType = try PointerClickType.from(clickTypeRaw)
            self.init(
                eventType: eventType,
                location: nil,
                screenNumber: nil,
                durationMs: nil,
                clickType: clickType,
                clickCount: nil,
                gapMs: nil,
                deltaX: nil,
                deltaY: nil,
            )
        case .scroll:
            let deltaX = container.decodeOptionalDouble(for: "deltaX")
            let deltaY = container.decodeOptionalDouble(for: "deltaY")
            let durationMs = container.decodeOptionalDouble(for: "duration_ms")
            self.init(
                eventType: eventType,
                location: nil,
                screenNumber: nil,
                durationMs: durationMs,
                clickType: nil,
                clickCount: nil,
                gapMs: nil,
                deltaX: deltaX,
                deltaY: deltaY,
            )
        }
    }
}

public struct PointerExecuteSequenceInput: RelaxedDecodable, Sendable {
    public let sequence: [PointerEvent]

    public init(sequence: [PointerEvent]) {
        self.sequence = sequence
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        var eventsContainer = try container.nestedUnkeyedContainer(for: "sequence")
        var events: [PointerEvent] = []
        while !eventsContainer.isAtEnd {
            let elementDecoder = try eventsContainer.superDecoder()
            let event = try PointerEvent(from: elementDecoder)
            events.append(event)
        }
        sequence = events
    }
}
