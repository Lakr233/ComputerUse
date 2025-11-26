//
//  IntelligentEffectView.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit
import Combine
import SnapKit

final class IntelligentEffectView: NSView {
    private let innerGrowView = IntelligentInnerGrowView()
    private let shimmerView = IntelligentShimmerView()

    @Published var currentFrame: NSRect = .zero
    private let workflow: Workflow
    private let viewModel: PointerViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: PointerViewModel, workflow: Workflow) {
        self.workflow = workflow
        self.viewModel = viewModel
        super.init(frame: .zero)

        alphaValue = 0

        addSubview(shimmerView)
        shimmerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(innerGrowView)
        innerGrowView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bindViewModelValues()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animator().alphaValue = 1
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func layout() {
        super.layout()
        currentFrame = frame
    }

    func setHover(pointInView: CGPoint) {
        shimmerView.setHover(pointInView: pointInView)
    }
}

private extension IntelligentEffectView {
    func bindViewModelValues() {
        let viewModel = viewModel
        Publishers.CombineLatest(
            viewModel.$mouseAbsoluteLocation,
            $currentFrame,
        )
        .map { absolutePoint, frame -> NSPoint in
            let screenFrame = viewModel.screen.frame
            let relativeX = min(max(absolutePoint.x - screenFrame.origin.x, 0), frame.width)
            let relativeY = min(max(absolutePoint.y - screenFrame.origin.y, 0), frame.height)
            return .init(x: relativeX, y: relativeY)
        }
        .removeDuplicates()
        .sink { [weak self] point in
            self?.setHover(pointInView: point)
        }
        .store(in: &cancellables)

        workflow.objectWillChange
            .receive(on: DispatchQueue.main) // delay one loop for object did change
            .map { [weak self] _ in self?.workflow.isRunning ?? false }
            .sink { [weak self] isExecuting in
                self?.innerGrowView.setExecuting(isExecuting: isExecuting)
            }
            .store(in: &cancellables)
    }
}
