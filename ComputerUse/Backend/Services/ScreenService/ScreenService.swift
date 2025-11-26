//
//  ScreenService.swift
//  ComputerUseKit
//

import AppKit
import AXSwift
import CoreGraphics
import Foundation
import ScreenCaptureKit

struct ScreenService {
    let pointerService: PointerService
    let displayService: DisplayService

    init(pointerService: PointerService, displayService: DisplayService = DisplayService()) {
        self.pointerService = pointerService
        self.displayService = displayService
    }

    let maxDepth = 8
    let maxElements = 128

    func captureScreenContext() async throws -> ScreenContext {
        // Get working screen, fallback to main screen if not set
        let workingScreen: NSScreen? = ScreenSelectorCheck.workingScreen ?? NSScreen.main ?? NSScreen.screens.first

        guard let screen = workingScreen else {
            throw ToolExecutionError.invalidOperation("No screen available")
        }

        // Get display ID from working screen
        let screenNumberString = ScreenSelectorCheck.screenNumber(screen)
        guard let screenNumber = Int(screenNumberString).map({ NSNumber(value: $0) }) else {
            throw ToolExecutionError.invalidOperation("Failed to get display ID for working screen")
        }
        let displayID = CGDirectDisplayID(screenNumber.uint32Value)

        // Capture screenshot using ScreenCaptureKit
        let image = try await captureScreenWithScreenCaptureKit(displayID: displayID)
        let encodedImage = encodeBase64(image: image)

        let pointer = try await pointerService.readPointer()
        let active = try activeApplicationContext(workingScreenBounds: screen.frame)

        return ScreenContext(
            screenshotBase64: encodedImage.base64,
            screenshotMediaType: encodedImage.mediaType,
            pointerLocation: pointer.location,
            pointerScreenNumber: pointer.screenNumber,
            activeApplication: active,
        )
    }

    func activeApplicationContext(workingScreenBounds: CGRect) throws -> ActiveApplication? {
        guard let nsApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let pid = nsApp.processIdentifier
        var windowTitle: String?
        var windowFrame: CGRect?
        var accessibility: [String: Any] = [:]

        if let appElement = Application(nsApp) {
            // Get focused window info
            if let windows = try? appElement.windows(), let first = windows.first {
                let title: String? = try? first.attribute(.title)
                windowTitle = title
                // Accessibility API returns Quartz coordinates (top-left origin)
                // Convert to Cocoa coordinates (bottom-left origin) for consistency
                if let quartzPosition: CGPoint = try? first.attribute(.position),
                   let size: CGSize = try? first.attribute(.size)
                {
                    let quartzFrame = CGRect(origin: quartzPosition, size: size)
                    windowFrame = convertQuartzFrameToCocoa(quartzFrame)
                }

                var elementCount = 0
                let elements = collectInteractiveElements(
                    from: first,
                    depth: 0,
                    elementCount: &elementCount,
                    workingScreenBounds: workingScreenBounds,
                )
                accessibility["interactive_elements"] = elements
            }

            if let focusedElement: UIElement = try? appElement.attribute(.focusedUIElement) {
                // Only include focused element if it's within working screen bounds
                if let focusedInfo = elementInfo(from: focusedElement),
                   isElementWithinWorkingScreen(focusedInfo, workingScreenBounds: workingScreenBounds)
                {
                    accessibility["focused_element"] = focusedInfo
                }
            }
        }

        return ActiveApplication(
            name: nsApp.localizedName,
            bundleIdentifier: nsApp.bundleIdentifier,
            processId: pid,
            windowTitle: windowTitle,
            windowFrame: windowFrame,
            accessibility: AnySendableDictionary(accessibility),
        )
    }
}
