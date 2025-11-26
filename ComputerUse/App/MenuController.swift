//
//  MenuController.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit
import Foundation

private let menuItemImage: NSImage = {
    let image = NSImage.menuItem
    image.size = NSSize(width: 22, height: 22)
    image.isTemplate = false
    return image
}()

@MainActor
class MenuController: NSObject {
    static let shared = MenuController()

    private let statusItem: NSStatusItem = NSStatusBar.system.statusItem(
        withLength: NSStatusItem.squareLength,
    )
    private let menu = NSMenu()

    override private init() {
        super.init()

        let button = statusItem.button!
        button.image = menuItemImage
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.toolTip = bundleVersionTitle()
        button.needsDisplay = true

        reloadMenuItems()
    }

    private func reloadMenuItems() {
        menu.autoenablesItems = false
        menu.removeAllItems()

        let versionItem = NSMenuItem(title: bundleVersionTitle(), action: nil, keyEquivalent: "")
        versionItem.isEnabled = false

        let resetConfigurationItem = NSMenuItem(title: "Select New Model", action: #selector(resetConfiguration(_:)), keyEquivalent: "")
        resetConfigurationItem.target = self

        let selectScreenItem = NSMenuItem(title: "Select New Screen", action: #selector(selectScreen(_:)), keyEquivalent: "")
        selectScreenItem.target = self

        let quitItem = NSMenuItem(title: String(localized: "Quit"), action: #selector(quitApp(_:)), keyEquivalent: "q")
        quitItem.target = self

        menu.addItem(versionItem)
        menu.addItem(.separator())
        menu.addItem(resetConfigurationItem)
        menu.addItem(selectScreenItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func bundleVersionTitle() -> String {
        let version = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleShortVersionString",
        ) as? String ?? "0.0"
        if let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion",
        ) as? String, !build.isEmpty {
            return String(localized: "Version \(version) (\(build))")
        }
        return String(localized: "Version \(version)")
    }

    @objc private func resetConfiguration(_: Any?) {
        ModelConfigurationViewModel.shared.openRouterToken = ""
        ModelConfigurationViewModel.shared.selectedModel = ""
        NSApp.restart()
    }

    @objc private func selectScreen(_: Any?) {
        ScreenSelectorViewModel.shared.workingScreenId = nil
        NSApp.restart()
    }

    @objc private func quitApp(_: Any?) {
        exit(0)
    }
}
