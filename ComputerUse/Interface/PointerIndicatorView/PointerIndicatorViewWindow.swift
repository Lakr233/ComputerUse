//
//  PointerIndicatorViewWindow.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit

class PointerOverlayIndicatorWindow: NoneInteractiveScreenWindow {
    convenience init(pin: NSScreen, viewModel: PointerViewModel) {
        self.init(contentView: PointerIndicatorView(viewModel: viewModel), pin: pin)
        layoutWindowContentView()
        orderFrontRegardless()
    }
}
