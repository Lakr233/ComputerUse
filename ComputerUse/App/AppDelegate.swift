//
//  AppDelegate.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import Cocoa

@MainActor
private let sky = SkyLightOperator(
    level: .kCGSSpaceAbsoluteLevelScreenLock,
    offsetAdding: -1,
)

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private(set) var workflow: Workflow!
    private(set) var pointerViewModel: PointerViewModel!
    private(set) var effectWindow: IntelligentEffectWindow!
    private(set) var pointerWindow: PointerOverlayIndicatorWindow!
    private(set) var controllerWindow: ControlPanelWindow!

    func applicationDidFinishLaunching(_: Notification) {
        _ = MenuController.shared
        NSApp.setActivationPolicy(.accessory)

        setupScreenMonitoring()

        print("[*] setting up pointer view model...")
        let workingScreen = ScreenSelectorCheck.workingScreen ?? .main!
        pointerViewModel = .init(screen: workingScreen)

        print("[*] setting up workflow...")
        workflow = .init(pointerViewModel: pointerViewModel)

        print("[*] setting up intelligent effect window...")
        effectWindow = IntelligentEffectWindow(
            pin: workingScreen,
            viewModel: pointerViewModel,
            workflow: workflow,
        )
        sky.delegateWindow(effectWindow!)

        print("[*] setting up pointer overlay indicator window...")
        pointerWindow = PointerOverlayIndicatorWindow(
            pin: workingScreen,
            viewModel: pointerViewModel,
        )
        sky.delegateWindow(pointerWindow!)

        print("[*] setting up the control panel...")
        controllerWindow = ControlPanelWindow(
            pin: workingScreen,
            viewModel: pointerViewModel,
            workflow: workflow,
        )
        sky.delegateWindow(controllerWindow)
    }

    func applicationWillTerminate(_: Notification) {
        NotificationCenter.default.removeObserver(self)
    }

    func applicationSupportsSecureRestorableState(_: NSApplication) -> Bool {
        true
    }

    private func setupScreenMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenConfigurationChanged(_:)),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil,
        )
    }

    @objc private func screenConfigurationChanged(_: Notification) {
        guard let workingScreenId = ScreenSelectorCheck.workingScreenId else { return }
        let screenExists = NSScreen.screens.contains { $0.id == workingScreenId }

        if !screenExists {
            print("[*] working screen disappeared, clearing and restarting...")
            ScreenSelectorViewModel.shared.workingScreenId = nil
            NSApp.restart()
        }
    }
}
