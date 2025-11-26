//
//  ScreenSelectorUI.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import SwiftUI

struct ScreenSelectorUI: App {
    var body: some Scene {
        WindowGroup {
            ScreenSelectorView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
