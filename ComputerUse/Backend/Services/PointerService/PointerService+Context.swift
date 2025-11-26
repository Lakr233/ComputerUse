//
//  PointerService+Context.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics

extension PointerService {
    func pointerContext(
        targetLocation: PointerLocation?,
    ) async throws -> PointerContext {
        await MainActor.run {
            let screen = viewModel.screen
            let absolutePoint: CGPoint
            if let targetLocation {
                let screenPoint = CGPoint(x: targetLocation.x, y: targetLocation.y)
                absolutePoint = viewModel.clampedLocation(for: screenPoint)
            } else {
                // 从 viewModel 读取鼠标位置，不从系统读取
                absolutePoint = viewModel.mouseAbsoluteLocation
            }
            let screenNumber = display.screenNumber(screen)

            return PointerContext(
                location: absolutePoint,
                screenNumber: screenNumber,
            )
        }
    }
}
