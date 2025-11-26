//
//  WorkflowTools+Definitions.swift
//  ComputerUseKit
//

import ChatClientKit
import Foundation

extension WorkflowTools {
    /*
     input: {"text": "note content"}
     output: {"status": "success", "note": "note content"}
     */
    static let workflowKeepNotesTool: ChatRequestBody.Tool = .function(
        name: "workflow_keep_notes",
        description: """
        Append a short note for the operator to surface in the control panel. Use for quick status, decisions, or next steps.
        """,
        parameters: [
            "type": "object",
            "properties": [
                "text": [
                    "type": "string",
                    "description": "Concise note to display to the user.",
                ],
            ],
            "required": ["text"],
            "additionalProperties": false,
        ],
        strict: nil,
    )

    /*
     input: {"text": "progress update"}
     output: {"status": "success", "progress": "progress update"}
     */
    static let workflowReportProgressTool: ChatRequestBody.Tool = .function(
        name: "workflow_report_progress",
        description: """
        Report current progress or state to show in the control panel. Use concise, user-facing language.
        """,
        parameters: [
            "type": "object",
            "properties": [
                "text": [
                    "type": "string",
                    "description": "Current progress summary.",
                ],
            ],
            "required": ["text"],
            "additionalProperties": false,
        ],
        strict: nil,
    )
}
