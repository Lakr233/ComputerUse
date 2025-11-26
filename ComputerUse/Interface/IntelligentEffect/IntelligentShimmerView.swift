//
//  IntelligentShimmerView.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import AppKit
import UIEffectKit

final class IntelligentShimmerView: NSView {
    private let shimmerView: ShimmerGridPointsView

    override init(frame frameRect: NSRect) {
        shimmerView = ShimmerGridPointsView(frame: frameRect)
        super.init(frame: frameRect)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor

        shimmerView.autoresizingMask = [.width, .height]
        shimmerView.frame = bounds
        addSubview(shimmerView)

        configureShimmerDefaults()
    }

    private func configureShimmerDefaults() {
        var config = ShimmerGridPointsView.Configuration()
        config.spacing = 16
        config.baseColor = SIMD3<Float>(1.0, 1.0, 1.0)
        config.waveSpeed = 2
        config.waveStrength = 0.5
        config.waveAngle = 270.0
        config.blurRange = 0.25 ... 0.5
        config.intensityRange = 0.1 ... 0.2
        config.radiusRange = 0.05 ... 0.1
        config.shapeMode = .diamonds
        config.enableWiggle = false
        config.hoverRadius = 80
        config.hoverBoost = 2
        config.enableEDR = true
        config.edrGain = 2.0
        shimmerView.configuration = config
    }

    func setHover(pointInView: CGPoint?) {
        shimmerView.setHover(pointInView: pointInView)
    }

    func updateConfiguration(_ config: ShimmerGridPointsView.Configuration) {
        shimmerView.configuration = config
    }

    override func layout() {
        super.layout()
        shimmerView.frame = bounds
    }
}
