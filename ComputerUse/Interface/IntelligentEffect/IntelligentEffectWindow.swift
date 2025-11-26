//
//  IntelligentEffectWindow.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit

class IntelligentEffectWindow: NoneInteractiveScreenWindow {
    convenience init(pin: NSScreen, viewModel: PointerViewModel, workflow: Workflow) {
        let view = IntelligentEffectView(viewModel: viewModel, workflow: workflow)
        self.init(contentView: view, pin: pin)
        layoutWindowContentView()
        orderFrontRegardless()
    }
}
