//
//  ControlPanelWindow.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import AppKit
import SwiftUI

class ControlPanelWindow: ScreenWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    convenience init(pin: NSScreen, viewModel: PointerViewModel, workflow: Workflow) {
        let view = ControlPanelView(viewModel: viewModel, workflow: workflow)
        self.init(contentView: view, pin: pin)
        layoutWindowContentView()
        orderFrontRegardless()
    }
}
