//
//  PointerService+ButtonState.swift
//  ComputerUseKit
//

import CoreGraphics

extension PointerService {
    func pointerButtons() -> [String: String] {
        let leftDown = CGEventSource.buttonState(.combinedSessionState, button: .left)
            ? "down" : "up"
        let rightDown = CGEventSource.buttonState(.combinedSessionState, button: .right)
            ? "down" : "up"
        let middleDown = CGEventSource.buttonState(.combinedSessionState, button: .center)
            ? "down" : "up"

        return [
            "left_button": leftDown,
            "right_button": rightDown,
            "middle_button": middleDown,
        ]
    }
}
