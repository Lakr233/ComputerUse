//
//  ToolInputModels+Workflow.swift
//  ComputerUseKit
//

import Foundation

public struct WorkflowKeepNotesInput: RelaxedDecodable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        text = try container.decodeString(for: "text")
    }
}

public struct WorkflowReportProgressInput: RelaxedDecodable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.relaxedContainer()
        text = try container.decodeString(for: "text")
    }
}
