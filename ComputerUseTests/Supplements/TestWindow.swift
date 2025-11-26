//
//  TestWindow.swift
//  ComputerUseTests
//
//  Full-screen test window that can receive keyboard and text input.
//

import AppKit
@testable import ComputerUse
import Foundation
import MSDisplayLink

@MainActor
class TestWindow: ScreenWindow {
    private var textField: NSTextField!
    private var button: NSButton!
    private var checkbox: NSButton!
    private var onTextReceived: ((String) -> Void)?
    private var onKeyReceived: ((String) -> Void)?
    private var displayLink: DisplayLink?

    convenience init(
        screen: NSScreen,
        onTextReceived: ((String) -> Void)? = nil,
        onKeyReceived: ((String) -> Void)? = nil,
        autoCloseAfter: TimeInterval? = nil,
    ) {
        self.init(contentView: NSView(), pin: screen)

        self.onTextReceived = onTextReceived
        self.onKeyReceived = onKeyReceived

        // Override some ScreenWindow defaults for testing
        isOpaque = true
        alphaValue = 0.5
        backgroundColor = NSColor.red.withAlphaComponent(0.5)
        level = .floating
        acceptsMouseMovedEvents = true
        isReleasedWhenClosed = false

        setupTextField()

        let link = DisplayLink()
        link.delegatingObject(self)
        displayLink = link

        layoutWindowContentView()

        if let autoCloseAfter {
            DispatchQueue.main.asyncAfter(deadline: .now() + autoCloseAfter) {
                if self.isVisible { self.close() }
            }
        }
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func close() {
        displayLink = nil
        NotificationCenter.default.removeObserver(self)
        super.close()
    }

    private func forceActivation() {
        guard isVisible else { return }
        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
        if let textField, firstResponder !== textField.currentEditor() {
            makeFirstResponder(textField)
        }
    }

    private func setupTextField() {
        let view = NSView()
        contentView = view

        // Text field with accessibility attributes
        textField = NSTextField(frame: NSRect(x: 100, y: 200, width: 400, height: 30))
        textField.placeholderString = "Type here for testing..."
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = true
        textField.backgroundColor = NSColor.white
        textField.textColor = NSColor.black
        textField.font = NSFont.systemFont(ofSize: 14)

        // Set accessibility attributes
        textField.setAccessibilityLabel("Test Input Field")
        textField.setAccessibilityTitle("Test Input Field")
        textField.setAccessibilityIdentifier("test-text-field")
        textField.setAccessibilityRoleDescription("Text input field for testing")
        textField.setAccessibilityHelp("This is a test text field used for keyboard input testing")

        view.addSubview(textField)

        // Button with accessibility attributes
        button = NSButton(frame: NSRect(x: 100, y: 150, width: 150, height: 30))
        button.title = "Test Button"
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(buttonClicked)

        // Set accessibility attributes
        button.setAccessibilityLabel("Test Button")
        button.setAccessibilityTitle("Test Button")
        button.setAccessibilityIdentifier("test-button")
        button.setAccessibilityRoleDescription("Button for testing")
        button.setAccessibilityHelp("This is a test button used for accessibility testing")

        view.addSubview(button)

        // Checkbox with accessibility attributes
        checkbox = NSButton(frame: NSRect(x: 100, y: 100, width: 200, height: 30))
        checkbox.setButtonType(.switch)
        checkbox.title = "Test Checkbox"
        checkbox.state = .off

        // Set accessibility attributes
        checkbox.setAccessibilityLabel("Test Checkbox")
        checkbox.setAccessibilityTitle("Test Checkbox")
        checkbox.setAccessibilityIdentifier("test-checkbox")
        checkbox.setAccessibilityRoleDescription("Checkbox for testing")
        checkbox.setAccessibilityHelp("This is a test checkbox used for accessibility testing")

        view.addSubview(checkbox)

        NSApp.activate(ignoringOtherApps: true)
        makeKeyAndOrderFront(nil)
        makeFirstResponder(textField)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange(_:)),
            name: NSTextField.textDidChangeNotification,
            object: textField,
        )
    }

    @objc private func buttonClicked() {
        print("[TestWindow] Button clicked")
    }

    @objc private func textDidChange(_ notification: Notification) {
        guard let textField = notification.object as? NSTextField else { return }
        let text = textField.stringValue
        onTextReceived?(text)
    }

    override func keyDown(with event: NSEvent) {
        let key = event.charactersIgnoringModifiers ?? ""
        onKeyReceived?(key)
        super.keyDown(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        print("[TestWindow] Mouse down at: \(location)")
        super.mouseDown(with: event)

        contentView?.layer?.backgroundColor = NSColor
            .random
            .withAlphaComponent(0.1)
            .cgColor
    }

    override func mouseUp(with event: NSEvent) {
        let location = event.locationInWindow
        print("[TestWindow] Mouse up at: \(location)")
        super.mouseUp(with: event)
    }

    func getTextFieldContent() -> String {
        textField?.stringValue ?? ""
    }

    func clearTextField() {
        textField?.stringValue = ""
    }
}

extension TestWindow: DisplayLinkDelegate {
    nonisolated func synchronization(context _: DisplayLinkCallbackContext) {
        MainActor.isolated { self.forceActivation() }
    }
}
