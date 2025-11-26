//
//  NoneInteractiveScreenWindow.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit

class NoneInteractiveScreenWindow: ScreenWindow {
    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool,
    ) {
        super.init(contentRect: contentRect, styleMask: styleMask, backing: backing, defer: flag)
        ignoresMouseEvents = true
    }

    override var canBecomeKey: Bool {
        false
    }

    override var canBecomeMain: Bool {
        false
    }
}
