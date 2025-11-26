//
//  DisplayService+ScreenQuery.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics

extension DisplayService {
    @discardableResult
    func screen(for number: String?) throws -> NSScreen {
        if let match = ScreenSelectorCheck.screen(for: number) {
            return match
        }
        if let main = NSScreen.main {
            return main
        }
        throw ToolExecutionError.missingScreen
    }
}
