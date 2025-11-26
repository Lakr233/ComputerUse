//
//  PointerService.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics
import Foundation

struct PointerService {
    struct PointerContext {
        let location: CGPoint
        let screenNumber: String
    }

    let display = DisplayService()
    let viewModel: PointerViewModel

    init(viewModel: PointerViewModel) {
        self.viewModel = viewModel
    }

    func summary(for event: PointerEvent) -> String {
        switch event.eventType {
        case .move:
            let loc = event.location.map { "(\($0.x), \($0.y))" } ?? "(unknown)"
            return "Move pointer to \(loc) on screen \(event.screenNumber ?? "main")"
        case .click:
            let click = event.clickType?.rawValue ?? "left"
            let count = event.clickCount ?? 1
            return "Click \(click) x\(count)"
        case .down:
            return "Mouse down \(event.clickType?.rawValue ?? "left")"
        case .up:
            return "Mouse up \(event.clickType?.rawValue ?? "left")"
        case .scroll:
            return "Scroll (\(event.deltaX ?? 0), \(event.deltaY ?? 0))"
        }
    }

    func readPointer() async throws -> PointerReadResult {
        let context = try await pointerContext(targetLocation: nil)

        return PointerReadResult(
            location: PointerLocation(x: context.location.x, y: context.location.y),
            screenNumber: context.screenNumber,
            pointerStatus: pointerButtons(),
        )
    }
}
