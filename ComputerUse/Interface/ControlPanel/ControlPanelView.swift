//
//  ControlPanelView.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import AppKit
import Combine
import SwiftUI

private let panelSize: CGSize = .init(width: 300, height: 120)
private let mouseOffset: CGSize = .init(width: 4, height: 4) // 鼠标到面板的偏移距离

class ControlPanelView: NSView {
    let viewModel: PointerViewModel
    let workflow: Workflow
    let panel: NSView

    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: PointerViewModel, workflow: Workflow) {
        self.viewModel = viewModel
        self.workflow = workflow
        panel = NSHostingView(
            rootView: ControlPanelContentView(workflow: workflow),
        )

        super.init(frame: .zero)

        wantsLayer = true
        addSubview(panel)
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupBindings() {
        viewModel.$mouseAbsoluteLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updatePointerPosition(absolutePoint: location)
            }
            .store(in: &cancellables)
    }

    private func updatePointerPosition(absolutePoint: CGPoint) {
        let screenFrame = viewModel.screen.frame
        let x = min(max(absolutePoint.x - screenFrame.origin.x, 0), bounds.width)
        let y = min(max(absolutePoint.y - screenFrame.origin.y, 0), bounds.height)
        var purposeFrame = CGRect(
            origin: .init(
                x: x + mouseOffset.width,
                y: y - mouseOffset.height - panelSize.height,
            ),
            size: panelSize,
        )

        // if maxX 超过了 bounds.maxX 挪到左边
        if purposeFrame.maxX > bounds.maxX {
            purposeFrame.origin.x = x - panelSize.width - mouseOffset.height
        }

        // if minY 小于 0 则挪到 pointer 上面去
        if purposeFrame.minY < 0 {
            purposeFrame.origin.y = y + mouseOffset.height
        }

        panel.frame = purposeFrame
    }
}
