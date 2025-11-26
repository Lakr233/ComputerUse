//
//  PointerViewModel+DisplayLink.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import Foundation
import MSDisplayLink
import SpringInterpolation

extension PointerViewModel: DisplayLinkDelegate {
    func synchronization(context: DisplayLinkCallbackContext) {
        MainActor.isolated { self.handleDisplayLinkTick(delta: context.duration) }
    }

    func handleDisplayLinkTick(delta: TimeInterval) {
        guard pendingMoveContinuation != nil else { return }
        advanceAnimator(delta: delta)
    }

    private func advanceAnimator(delta: TimeInterval) {
        mouseLocationAnimator.update(withDeltaTime: delta)
        let location = clampedLocation(
            for: .init(
                x: mouseLocationAnimator.x.value,
                y: mouseLocationAnimator.y.value,
            ),
        )
        mouseAbsoluteLocation = location

        if mouseLocationAnimator.completed,
           let pendingMoveContinuation
        {
            self.pendingMoveContinuation = nil
            pendingMoveContinuation.resume(returning: ())
        }
    }
}
