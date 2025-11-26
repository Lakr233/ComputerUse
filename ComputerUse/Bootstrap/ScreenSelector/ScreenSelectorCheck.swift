//
//  ScreenSelectorCheck.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit
import Foundation
import SwiftUI

@Observable
@MainActor
final class ScreenSelectorViewModel {
    nonisolated static let shared = MainActor.isolated { ScreenSelectorViewModel() }

    private let workingScreenIdKey = "com.computeruse.workingScreenId"

    var workingScreenId: Int? {
        get {
            let value = UserDefaults.standard.integer(forKey: workingScreenIdKey)
            return value != 0 ? value : nil
        }
        set {
            if let id = newValue {
                UserDefaults.standard.set(id, forKey: workingScreenIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: workingScreenIdKey)
            }
        }
    }

    nonisolated var workingScreen: NSScreen? {
        let id = MainActor.isolated { self.workingScreenId }
        return NSScreen.screens.first { $0.id == id }
    }

    var hasWorkingScreen: Bool {
        workingScreen != nil
    }

    private init() {}
}

@MainActor
enum ScreenSelectorCheck {
    static var hasWorkingScreen: Bool {
        ScreenSelectorViewModel.shared.hasWorkingScreen
    }

    nonisolated static var workingScreen: NSScreen? {
        ScreenSelectorViewModel.shared.workingScreen
    }

    static var workingScreenId: Int? {
        ScreenSelectorViewModel.shared.workingScreenId
    }

    nonisolated static func screen(for number: String?) -> NSScreen? {
        guard let number else { return nil }
        return NSScreen.screens.first { screen in
            let value = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
            return value?.stringValue == number
        }
    }

    nonisolated static func screenNumber(_ screen: NSScreen) -> String {
        let value = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber
        return value?.stringValue ?? "0"
    }

    static func requiresInteraction() -> Bool {
        !hasWorkingScreen
    }

    static func prompt() -> Never {
        ScreenSelectorUI.main()
        fatalError()
    }
}
