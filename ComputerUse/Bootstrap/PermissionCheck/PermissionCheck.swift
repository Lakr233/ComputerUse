//
//  PermissionCheck.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit
import AXSwift
import CoreGraphics
import SwiftUI

enum PermissionCheck {
    static var isAccessibilityTrusted: Bool {
        checkIsProcessTrusted(prompt: false)
    }

    static var isScreenCaptureAuthorized: Bool {
        CGPreflightScreenCaptureAccess()
    }

    static func requiresInteraction() -> Bool {
        [
            isAccessibilityTrusted,
            isScreenCaptureAuthorized,
        ].contains(false)
    }

    static func promptAccessibilityDialog() {
        print("[*] prompting accessibility permission dialog")
        checkIsProcessTrusted(prompt: true)
    }

    static func promptScreenCaptureDialog() {
        print("[*] prompting screen capture permission dialog")
        CGRequestScreenCaptureAccess()
    }

    static func prompt() -> Never {
        PermissionUI.main()
        fatalError()
    }
}
