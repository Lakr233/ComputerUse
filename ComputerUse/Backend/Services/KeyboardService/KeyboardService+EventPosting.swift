//
//  KeyboardService+EventPosting.swift
//  ComputerUseKit
//

import ApplicationServices
import Carbon.HIToolbox.Events

extension KeyboardService {
    func postKeyEvent(code: CGKeyCode, isKeyDown: Bool) {
        let flags = effectiveFlags(including: code)
        let ev = CGEvent(keyboardEventSource: nil, virtualKey: code, keyDown: isKeyDown)
        ev?.flags = flags
        ev?.post(tap: .cghidEventTap)
    }

    func effectiveFlags(including code: CGKeyCode) -> CGEventFlags {
        var flags: CGEventFlags = []
        var activeKeys = pressedKeys
        activeKeys.insert(code)
        for key in activeKeys {
            guard let carbonKey = CarbonKeys(keyCode: key), let flag = carbonKey.eventFlag else { continue }
            flags.insert(flag)
        }
        return flags
    }

    func postUnicode(_ text: String) {
        let utf16 = Array(text.utf16)
        let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
        event?.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
        event?.post(tap: .cghidEventTap)
    }
}
