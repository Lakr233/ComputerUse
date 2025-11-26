//
//  DisplayService.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics

struct DisplayService {
    func screenNumber(_ screen: NSScreen) -> String {
        ScreenSelectorCheck.screenNumber(screen)
    }

    func globalPoint(for location: PointerLocation, on screenNumber: String?) throws -> CGPoint {
        let screen = try screen(for: screenNumber)
        let bounds = screen.frame
        return CGPoint(x: bounds.origin.x + location.x, y: bounds.origin.y + location.y)
    }
}
