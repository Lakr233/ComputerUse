//
//  PointerViewModel.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit
import Combine
import CoreGraphics
import MSDisplayLink
import SpringInterpolation
import os

@MainActor
class PointerViewModel: NSObject, ObservableObject {
    let activateScreenIdentifier: NSScreen.ID
    let screen: NSScreen

    @Published var mouseAbsoluteLocation: CGPoint = .zero
    @Published var mouseClickCount: UInt64 = 0

    // 按照左下角原点给
    var mouseLocationInScreen: CGPoint {
        mouseAbsoluteLocation
    }

    private let displayLink = DisplayLink()
    var mouseLocationAnimator = SpringInterpolation2D(.init(
        angularFrequency: 10,
        dampingRatio: 1.0,
        threshold: 0.00001,
        stopWhenHitTarget: true,
    ))
    var pendingMoveContinuation: CheckedContinuation<Void, Never>?

    init(screen: NSScreen) {
        activateScreenIdentifier = screen.id
        self.screen = screen
        super.init()
        mouseAbsoluteLocation = PointerViewModel.center(of: screen.frame)
        displayLink.delegatingObject(self)

        mouseLocationAnimator.setCurrent(
            .init(
                x: mouseAbsoluteLocation.x,
                y: mouseAbsoluteLocation.y,
            ),
            vel: .init(x: 0, y: 0),
        )
        mouseLocationAnimator.setTarget(
            .init(
                x: mouseAbsoluteLocation.x,
                y: mouseAbsoluteLocation.y,
            ),
        )
    }

    @MainActor
    func moveMouse(to point: CGPoint) async {
        logger.info("\(#fileID) \(#function) to: \(String(describing: point))")
        if let pendingMoveContinuation {
            self.pendingMoveContinuation = nil
            pendingMoveContinuation.resume(returning: ())
        }

        let clampedPoint = clampedLocation(for: point)
        mouseLocationAnimator.setTarget(
            .init(
                x: clampedPoint.x,
                y: clampedPoint.y,
            ),
        )

        await withCheckedContinuation { continuation in
            pendingMoveContinuation = continuation
        }
    }

    @MainActor
    func clickCountIncrease() {
        mouseClickCount += 1
    }

    func clampedLocation(for point: CGPoint) -> CGPoint {
        let bounds = screen.frame
        return .init(
            x: min(max(point.x, bounds.minX), bounds.maxX),
            y: min(max(point.y, bounds.minY), bounds.maxY),
        )
    }

    /// 将 Cocoa 坐标（左下角原点）转换为 Quartz 坐标（左上角原点）
    /// CGWarpMouseCursorPosition 使用 Quartz 坐标系
    func quartzLocation(for cocoaPoint: CGPoint) -> CGPoint {
        // Cocoa 坐标系：原点在主屏幕左下角，Y 向上增加
        // Quartz 坐标系：原点在主屏幕左上角，Y 向下增加
        // 转换公式：quartzY = 主屏幕高度 - cocoaY
        guard let primaryScreen = NSScreen.screens.first else {
            return cocoaPoint
        }
        let primaryScreenHeight = primaryScreen.frame.height
        return CGPoint(
            x: cocoaPoint.x,
            y: primaryScreenHeight - cocoaPoint.y,
        )
    }

    private static func center(of rect: CGRect) -> CGPoint {
        .init(x: rect.midX, y: rect.midY)
    }
}
