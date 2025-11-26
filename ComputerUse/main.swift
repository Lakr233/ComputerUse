//
//  main.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit
import os

let logger = Logger(
    subsystem: "wiki.qaq.logger",
    category: "main",
)

MainActor.isolated {
    if PermissionCheck.requiresInteraction() { PermissionCheck.prompt() }
    if ScreenSelectorCheck.requiresInteraction() { ScreenSelectorCheck.prompt() }
    if ModelConfigurationCheck.requiresInteraction() { ModelConfigurationCheck.prompt() }

    print("[*] launching application")

    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate
    let ret = NSApplicationMain(
        CommandLine.argc,
        CommandLine.unsafeArgv,
    )
    exit(ret)
}
