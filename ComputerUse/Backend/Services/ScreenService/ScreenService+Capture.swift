//
//  ScreenService+Capture.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics
import ScreenCaptureKit

extension ScreenService {
    func captureScreenWithScreenCaptureKit(displayID: CGDirectDisplayID) async throws -> CGImage {
        guard CGPreflightScreenCaptureAccess() else {
            throw ToolExecutionError.invalidOperation("No screen capture permission")
        }

        let shareableContent = try await SCShareableContent.current

        guard let display = shareableContent.displays.first(where: { $0.displayID == displayID }) else {
            throw ToolExecutionError.invalidOperation("Failed to find display with ID \(displayID) in shareable content")
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])

        let displayScaleFactor: Int = if let mode = CGDisplayCopyDisplayMode(displayID) {
            mode.pixelWidth / mode.width
        } else {
            1
        }

        let configuration = SCStreamConfiguration()
        configuration.width = Int(display.width) * displayScaleFactor
        configuration.height = Int(display.height) * displayScaleFactor
        configuration.showsCursor = false
        configuration.pixelFormat = kCVPixelFormatType_32BGRA
        configuration.colorSpaceName = CGColorSpace.sRGB

        let image = try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: configuration,
        )

        return image
    }
}
