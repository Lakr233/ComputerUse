//
//  PermissionUI.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import SwiftUI

struct PermissionUI: App {
    var body: some Scene {
        WindowGroup {
            PermissionView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
