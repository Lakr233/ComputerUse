//
//  PointerService+EventHandling.swift
//  ComputerUseKit
//

import AppKit
import Combine
import CoreGraphics
import os

extension PointerService {
    func perform(event: PointerEvent) async throws {
        switch event.eventType {
        case .move:
            alignPointerToViewModel()
            guard event.location != nil else {
                throw ToolExecutionError.invalidOperation("Move event requires location")
            }
            let context = try await pointerContext(
                targetLocation: event.location,
            )
            let cancellable: AnyCancellable = MainActor.isolated {
                viewModel.$mouseAbsoluteLocation
                    .sink { [viewModel] point in
                        let quartzPoint = viewModel.quartzLocation(for: point)
                        CGWarpMouseCursorPosition(quartzPoint)
                    }
            }
            await viewModel.moveMouse(to: context.location)
            cancellable.cancel()
            await MainActor.run {
                viewModel.mouseAbsoluteLocation = context.location
            }
        case .click:
            alignPointerToViewModel()
            let button = mouseButton(event.clickType)
            let count = event.clickCount ?? 1
            let position = MainActor.isolated {
                viewModel.quartzLocation(for: viewModel.mouseAbsoluteLocation)
            }
            let types = clickSequence(for: button)
            let down = CGEvent(
                mouseEventSource: nil,
                mouseType: types.down,
                mouseCursorPosition: position,
                mouseButton: button,
            )
            let up = CGEvent(
                mouseEventSource: nil,
                mouseType: types.up,
                mouseCursorPosition: position,
                mouseButton: button,
            )
            for _ in 0 ..< count {
                await viewModel.clickCountIncrease()
                down?.post(tap: .cghidEventTap)
                up?.post(tap: .cghidEventTap)
            }
        case .down:
            alignPointerToViewModel()
            await viewModel.clickCountIncrease()
            let button = mouseButton(event.clickType)
            let position = MainActor.isolated {
                viewModel.quartzLocation(for: viewModel.mouseAbsoluteLocation)
            }
            let type = clickSequence(for: button).down
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: type,
                mouseCursorPosition: position,
                mouseButton: button,
            )
            event?.post(tap: .cghidEventTap)
        case .up:
            alignPointerToViewModel()
            await viewModel.clickCountIncrease()
            let button = mouseButton(event.clickType)
            let position = MainActor.isolated {
                viewModel.quartzLocation(for: viewModel.mouseAbsoluteLocation)
            }
            let type = clickSequence(for: button).up
            let event = CGEvent(
                mouseEventSource: nil,
                mouseType: type,
                mouseCursorPosition: position,
                mouseButton: button,
            )
            event?.post(tap: .cghidEventTap)
        case .scroll:
            alignPointerToViewModel()
            let dx = event.deltaX ?? 0
            let dy = event.deltaY ?? 0
            let scrollEvent = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,
                wheelCount: 2,
                wheel1: Int32(dy),
                wheel2: Int32(dx),
                wheel3: 0,
            )
            scrollEvent?.post(tap: .cghidEventTap)
        }
    }

    private func mouseButton(_ type: PointerClickType?) -> CGMouseButton {
        switch type {
        case .right:
            .right
        case .middle:
            .center
        default:
            .left
        }
    }

    private func clickSequence(for button: CGMouseButton) -> (down: CGEventType, up: CGEventType) {
        switch button {
        case .right:
            (.rightMouseDown, .rightMouseUp)
        case .center:
            (.otherMouseDown, .otherMouseUp)
        default:
            (.leftMouseDown, .leftMouseUp)
        }
    }

    private func alignPointerToViewModel() {
        let quartzPoint = MainActor.isolated {
            viewModel.quartzLocation(for: viewModel.mouseAbsoluteLocation)
        }
        logger.info("moving pointer to view model location: \(String(describing: quartzPoint))")
        CGWarpMouseCursorPosition(quartzPoint)
    }
}
