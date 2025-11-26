//
//  ScreenWindow.swift
//  FireBox
//
//  Created by 秋星桥 on 2024/2/9.
//

import AppKit

@MainActor
class ScreenWindow: NSWindow {
    private(set) var screenIdentifier: NSScreen.ID?

    convenience init(contentView: NSView, pin: NSScreen) {
        self.init(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: false)
        screenIdentifier = pin.id
        self.contentView = contentView
    }

    override init(
        contentRect: NSRect,
        styleMask: NSWindow.StyleMask,
        backing: NSWindow.BackingStoreType,
        defer flag: Bool,
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: styleMask,
            backing: backing,
            defer: flag,
        )

        isOpaque = false
        alphaValue = 1
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        backgroundColor = NSColor.clear
        isMovable = false
        collectionBehavior = [
            .fullScreenAuxiliary,
            .stationary,
            .canJoinAllSpaces,
            .ignoresCycle,
        ]
        level = .statusBar
        hasShadow = false
        animationBehavior = .none

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(layoutWindowContentView),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil,
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func layoutWindowContentView() {
        print("[*] layout window for screen changes.")
        guard let screenIdentifier else { return }
        guard let contentView else { return }
        let screen = NSScreen.screens.first(where: { $0.id == screenIdentifier })
        guard let screen else { return } // probably just close button
        setFrame(screen.frame, display: true)
        contentView.frame = NSRect(origin: .zero, size: screen.frame.size)
        print("[*] screen window updated to frame: \(screen.frame)")
    }
}
