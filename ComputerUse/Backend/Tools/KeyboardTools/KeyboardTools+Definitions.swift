//
//  KeyboardTools+Definitions.swift
//  ComputerUseKit
//

import ChatClientKit
import Foundation

extension KeyboardTools {
    /*
     input: {
        "sequence": [
            {"eventType":"keydown","key":"shift"},
            {"eventType":"keydown","key":"a"},
            {"eventType":"keyup","key":"a"},
            {"eventType":"keyup","key":"shift"},
            {"eventType":"text","text":"hello"},
            {"eventType":"delay","duration_ms":120}
        ]
     }
     output: {"status": "success", "hint": "best-effort parsing; invalid items will surface with an error hint"}
     */
    static let keyboardExecuteSequenceTool: ChatRequestBody.Tool = .function(
        name: "computer_use_keyboard",
        description: """
        Execute a sequence of keyboard events (keydown, keyup, text, delay).
        Schema (best-effort parsed, hints returned on errors):
        {
          "sequence": [
            {"eventType":"keydown","key":"shift"},
            {"eventType":"keydown","key":"a"},
            {"eventType":"keyup","key":"a"},
            {"eventType":"keyup","key":"shift"},
            {"eventType":"text","text":"hello"},
            {"eventType":"delay","duration_ms":120}
          ]
        }
        Allowed eventType: keydown | keyup | text | delay.
        Key names (US layout) include: a–z, 0–9, minus, equal, leftbracket, rightbracket, backslash, semicolon, quote, comma, period, slash, grave, return, tab, space, delete, escape, command, shift, capslock, option, control, rightshift, rightoption, rightcontrol, fn/function/globe, arrowleft, arrowright, arrowup, arrowdown.
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

    /*
     input: {"text": "hello world"}
     output: {"status": "success"}
     */
    static let keyboardExecuteInputTool: ChatRequestBody.Tool = .function(
        name: "computer_use_keyboard_text",
        description: """
        Type raw text input using the keyboard.
        """,
        parameters: [
            "type": "object",
            "properties": [
                "text": [
                    "type": "string",
                    "description": "Plain text to type exactly as provided.",
                ],
            ],
            "required": ["text"],
            "additionalProperties": false,
        ],
        strict: nil,
    )
}
