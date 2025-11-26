//
//  PointerTools+Definitions.swift
//  ComputerUseKit
//

import ChatClientKit
import Foundation

extension PointerTools {
    /*
     input: {}
     output: {
        "status": "success",
        "location": {"x":100,"y":200},
        "screenNumber": "xxx",
        "pointer_status": {"left_button": "up" | "down", "right_button": "up" | "down", "middle_button": "up" | "down"}
     }
     */
    static let pointerReadLocationTool: ChatRequestBody.Tool = .function(
        name: "computer_use_pointer_location",
        description: """
        Read current pointer location, screen number and button state.
        """,
        parameters: [
            "type": "object",
            "properties": [:],
            "additionalProperties": false,
        ],
        strict: nil,
    )

    /*
     input: {
        "sequence": [
            {"eventType": "move", "location": {"x":100,"y":200}, "screenNumber": "xxx", "duration_ms": 0.5},
            {"eventType": "click", "clickType": "left" | "right" | "middle", "clickCount": 1 | 2 | 3, "gap_ms": 10},
            {"eventType": "down", "clickType": "left" | "right" | "middle"},
            {"eventType": "up", "clickType": "left" | "right" | "middle"},
            {"eventType": "move", "location": {"x":100,"y":200}, "screenNumber": "xxx", "duration_ms": 0.5},
            {"eventType": "scroll", "deltaX": 0, "deltaY": -100, "duration_ms": 100},
        ]
     }
     output: {"status": "success"}
     */
    static let pointerExecuteSequenceTool: ChatRequestBody.Tool = .function(
        name: "computer_use_pointer",
        description: """
        Execute a sequence of pointer actions (move, click, down/up, scroll).
        Schema (best-effort parsed, hints returned on errors):
        {
          "sequence": [
            {"eventType":"move","location":{"x":0,"y":0},"screenNumber":"0","duration_ms":150},
            {"eventType":"click","clickType":"left","clickCount":1,"gap_ms":10},
            {"eventType":"down","clickType":"left"},
            {"eventType":"up","clickType":"left"},
            {"eventType":"scroll","deltaX":0,"deltaY":-120,"duration_ms":120}
          ]
        }
        Allowed eventType: move | click | down | up | scroll
        Optional fields by event:
        - move: location{ x,y }, screenNumber, duration_ms
        - click: clickType(left|right|middle), clickCount(1-3), gap_ms
        - down/up: clickType(left|right|middle)
        - scroll: deltaX, deltaY, duration_ms
        Coordinates use macOS Cocoa coordinate system (origin at bottom-left of primary screen, Y increases upward).
        """,
        parameters: [
            "type": "object",
            "properties": [
                "sequence": [
                    "type": "array",
                    "items": [
                        "type": "object",
                    ],
                ],
            ],
            "required": ["sequence"],
            "additionalProperties": false,
        ],
        strict: nil,
    )
}
