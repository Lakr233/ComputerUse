//
//  PointerIndicatorView.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit
import Combine

enum PointerIndicatorConstants {
    static let pointerSize: CGFloat = 32
    static let hotSpotSize: CGFloat = 4
    static let hotSpotLocationRatio = CGPoint(x: 0.2, y: 0.8)
}

class PointerIndicatorView: NSView {
    private let viewModel: PointerViewModel
    private var cancellables: Set<AnyCancellable> = []

    private let pointerImageView: NSImageView = {
        let imageView = NSImageView()
        imageView.image = .init(
            systemSymbolName: "pointer.arrow.ipad",
            accessibilityDescription: nil,
        )
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.frame = CGRect(x: 0, y: 0, width: PointerIndicatorConstants.pointerSize, height: PointerIndicatorConstants.pointerSize)
        imageView.wantsLayer = true
        imageView.layer?.shadowColor = NSColor.black.cgColor
        imageView.layer?.shadowOpacity = 0.25
        imageView.layer?.shadowRadius = 4
        return imageView
    }()

    init(viewModel: PointerViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        wantsLayer = true
        addSubview(pointerImageView)
        updateTintColor()
        setupBindings()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBindings() {
        viewModel.$mouseAbsoluteLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updatePointerPosition(location: location)
            }
            .store(in: &cancellables)

        viewModel.$mouseClickCount
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.animatePointerScale()
            }
            .store(in: &cancellables)
    }

    private func updatePointerPosition(location: CGPoint) {
        let screenFrame = viewModel.screen.frame
        let relativeX = min(max(location.x - screenFrame.origin.x, 0), bounds.width)
        let relativeY = min(max(location.y - screenFrame.origin.y, 0), bounds.height)

        let hotSpotOffsetX = PointerIndicatorConstants.pointerSize * PointerIndicatorConstants.hotSpotLocationRatio.x
        let hotSpotOffsetY = PointerIndicatorConstants.pointerSize * PointerIndicatorConstants.hotSpotLocationRatio.y
        let pointerOrigin = CGPoint(
            x: relativeX - hotSpotOffsetX,
            y: relativeY - hotSpotOffsetY,
        )
        pointerImageView.frame.origin = pointerOrigin
    }

    private func animatePointerScale() {
        guard let layer = pointerImageView.layer else { return }

        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.85, 1.0]
        scaleAnimation.keyTimes = [0, 0.15, 1.0]
        scaleAnimation.duration = 0.3
        scaleAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
        ]
        scaleAnimation.fillMode = .forwards
        scaleAnimation.isRemovedOnCompletion = true
        layer.add(scaleAnimation, forKey: "pointerScale")
    }

    override func layout() {
        super.layout()
        updatePointerPosition(location: viewModel.mouseAbsoluteLocation)
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        updateTintColor()
    }

    private func updateTintColor() {
        pointerImageView.contentTintColor = .labelColor.withAlphaComponent(0.75)
    }
}
