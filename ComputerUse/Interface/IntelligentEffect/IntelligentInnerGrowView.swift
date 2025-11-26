//
//  IntelligentInnerGrowView.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit
import ColorfulX
import SnapKit
import UIEffectKit

private let kEdgeInset: CGFloat = 1
private let kCornerRadius: CGFloat = 18.5
private let kShadowBlur: CGFloat = 16
private let kShadowBlurMultiplier: CGFloat = 2
private let kExpandedBoundsMultiplier: CGFloat = 2

final class IntelligentInnerGrowView: NSView {
    private let colorful: AnimatedMulticolorGradientView = {
        let director = SpeckleAnimationRoundedRectangleDirector(
            inset: 0.1,
            cornerRadius: 1,
            direction: .clockwise,
            movementRate: 0.1,
            positionResponseRate: 1,
        )
        let view = AnimatedMulticolorGradientView(
            animationDirector: director,
        )
        view.setColors([.clear], animated: false, repeats: true)
        view.speed *= 2
        view.noise = 0
        view.renderScale = 0.1
        view.bias /= 5_000_000
        view.transitionSpeed *= 10
        view.frameLimit = 15
        return view
    }()

    private let maskLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        wantsLayer = true
        addSubview(colorful)
        colorful.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        colorful.layer?.mask = maskLayer
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        setupMask()

        CATransaction.commit()
    }

    private func setupMask() {
        let scale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
        let size = bounds.size

        guard size.width > 0, size.height > 0 else { return }

        let innerRect = bounds.insetBy(dx: kEdgeInset, dy: kEdgeInset)

        // Create the inner path (with rounded corners)
        let innerPath = CGPath(
            roundedRect: innerRect,
            cornerWidth: kCornerRadius,
            cornerHeight: kCornerRadius,
            transform: nil,
        )

        // Outer bounds path (NO rounded corners - square edges to match screen)
        let outerPath = CGPath(rect: bounds, transform: nil)

        // We want: outer edge opacity=1 (solid), fading INWARD to opacity=0
        // Strategy:
        // 1. Draw the solid border frame (outer - inner) with full opacity
        // 2. Add inner shadow that fades inward from the inner edge

        let expandedBounds = bounds.insetBy(dx: -kShadowBlur, dy: -kShadowBlur)

        guard let context = CGContext(
            data: nil,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
        ) else { return }

        context.scaleBy(x: scale, y: scale)
        context.clear(CGRect(origin: .zero, size: size))

        // Clip everything to the outer rect first
        context.saveGState()
        context.addPath(outerPath)
        context.clip()

        // Step 1: Draw the solid border frame (outer rect minus inner rect)
        let framePath = CGMutablePath()
        framePath.addPath(outerPath)
        framePath.addPath(innerPath)

        context.setFillColor(NSColor.white.cgColor)
        context.addPath(framePath)
        context.drawPath(using: .eoFill)

        // Step 2: Add inner shadow that extends inward from the inner edge
        // Clip to the inner rect area to draw the shadow
        context.saveGState()
        context.addPath(innerPath)
        context.clip()

        // Draw a large frame with hole, shadow casts inward
        let shadowFramePath = CGMutablePath()
        shadowFramePath.addRect(expandedBounds)
        shadowFramePath.addPath(innerPath)

        // Set shadow - this will cast INTO the hole (inward)
        context.setShadow(offset: .zero, blur: kShadowBlur * kShadowBlurMultiplier, color: NSColor.white.cgColor)

        // Fill the frame (with hole) - shadow casts inward
        context.setFillColor(NSColor.white.cgColor)
        context.addPath(shadowFramePath)
        context.drawPath(using: .eoFill)

        context.restoreGState()
        context.restoreGState()

        guard let finalImage = context.makeImage() else { return }

        maskLayer.contents = finalImage
        maskLayer.frame = bounds
        maskLayer.contentsScale = scale
    }
}

extension IntelligentInnerGrowView {
    func setExecuting(isExecuting: Bool) {
        if isExecuting {
            colorful.setColors(.appleIntelligence, animated: true)
        } else {
            colorful.setColors([.clear], animated: true, repeats: true)
        }
    }
}
