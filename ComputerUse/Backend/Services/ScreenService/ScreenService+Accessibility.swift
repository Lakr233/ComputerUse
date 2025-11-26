//
//  ScreenService+Accessibility.swift
//  ComputerUseKit
//

import AppKit
import AXSwift
import CoreGraphics

extension ScreenService {
    // MARK: - Coordinate Conversion

    /// Converts Quartz coordinates (top-left origin) to Cocoa coordinates (bottom-left origin)
    /// Accessibility API uses Quartz coordinate system
    func convertQuartzToCocoa(_ quartzPoint: CGPoint) -> CGPoint {
        // Get the primary screen height for conversion
        // Quartz origin is at top-left of primary screen
        // Cocoa origin is at bottom-left of primary screen
        guard let primaryScreen = NSScreen.screens.first else {
            return quartzPoint
        }
        let primaryScreenHeight = primaryScreen.frame.height
        return CGPoint(
            x: quartzPoint.x,
            y: primaryScreenHeight - quartzPoint.y,
        )
    }

    /// Converts a Quartz frame to Cocoa frame
    func convertQuartzFrameToCocoa(_ quartzFrame: CGRect) -> CGRect {
        guard let primaryScreen = NSScreen.screens.first else {
            return quartzFrame
        }
        let primaryScreenHeight = primaryScreen.frame.height
        // The y coordinate in Cocoa is the bottom of the frame
        // In Quartz, y is the top of the frame
        let cocoaY = primaryScreenHeight - quartzFrame.origin.y - quartzFrame.height
        return CGRect(
            x: quartzFrame.origin.x,
            y: cocoaY,
            width: quartzFrame.width,
            height: quartzFrame.height,
        )
    }

    // MARK: - Accessibility Element Collection

    func collectInteractiveElements(
        from element: UIElement,
        depth: Int,
        elementCount: inout Int,
        workingScreenBounds: CGRect,
    ) -> [[String: Any]] {
        guard depth < maxDepth, elementCount < maxElements else { return [] }

        var results: [[String: Any]] = []

        if let info = elementInfo(from: element),
           isInteractiveElement(info),
           isElementWithinWorkingScreen(info, workingScreenBounds: workingScreenBounds)
        {
            results.append(info)
            elementCount += 1
        }

        if let children: [UIElement] = try? element.arrayAttribute(.children) {
            for child in children {
                guard elementCount < maxElements else { break }
                let childElements = collectInteractiveElements(
                    from: child,
                    depth: depth + 1,
                    elementCount: &elementCount,
                    workingScreenBounds: workingScreenBounds,
                )
                results.append(contentsOf: childElements)
            }
        }

        return results
    }

    func isElementWithinWorkingScreen(_ info: [String: Any], workingScreenBounds: CGRect) -> Bool {
        guard let frameDict = info["frame"] as? [String: Any],
              let x = frameDict["x"] as? CGFloat,
              let y = frameDict["y"] as? CGFloat,
              let width = frameDict["width"] as? CGFloat,
              let height = frameDict["height"] as? CGFloat
        else {
            // If element has no frame info, exclude it to be safe
            return false
        }

        let elementFrame = CGRect(x: x, y: y, width: width, height: height)

        // Check if element frame intersects with working screen bounds
        return elementFrame.intersects(workingScreenBounds)
    }

    func elementInfo(from element: UIElement) -> [String: Any]? {
        var info: [String: Any] = [:]

        guard let role: String = try? element.attribute(.role) else { return nil }
        info["role"] = role

        if let roleDesc: String = try? element.attribute(.roleDescription) {
            info["role_description"] = roleDesc
        }

        if let title: String = try? element.attribute(.title), !title.isEmpty {
            info["title"] = title
        }
        if let label: String = try? element.attribute(.description), !label.isEmpty {
            info["label"] = label
        }
        if let value: Any = try? element.attribute(.value) {
            if let stringValue = value as? String, !stringValue.isEmpty {
                info["value"] = stringValue
            } else if let numberValue = value as? NSNumber {
                info["value"] = numberValue
            }
        }

        if let identifier: String = try? element.attribute(.identifier), !identifier.isEmpty {
            info["identifier"] = identifier
        }

        // Accessibility API returns Quartz coordinates (top-left origin)
        // Convert to Cocoa coordinates (bottom-left origin) for consistency
        if let quartzPosition: CGPoint = try? element.attribute(.position),
           let size: CGSize = try? element.attribute(.size)
        {
            let quartzFrame = CGRect(origin: quartzPosition, size: size)
            let cocoaFrame = convertQuartzFrameToCocoa(quartzFrame)
            info["frame"] = [
                "x": cocoaFrame.origin.x,
                "y": cocoaFrame.origin.y,
                "width": cocoaFrame.width,
                "height": cocoaFrame.height,
            ]
        }

        if let enabled: Bool = try? element.attribute(.enabled) {
            info["enabled"] = enabled
        }

        if let focused: Bool = try? element.attribute(.focused) {
            info["focused"] = focused
        }

        if let selected: Bool = try? element.attribute(.selected) {
            info["selected"] = selected
        }

        return info
    }

    private func isInteractiveElement(_ info: [String: Any]) -> Bool {
        guard let role = info["role"] as? String else { return false }

        let interactiveRoles: Set<String> = [
            "AXButton",
            "AXLink",
            "AXTextField",
            "AXTextArea",
            "AXCheckBox",
            "AXRadioButton",
            "AXPopUpButton",
            "AXComboBox",
            "AXSlider",
            "AXIncrementor",
            "AXColorWell",
            "AXMenuItem",
            "AXMenuButton",
            "AXMenuBarItem",
            "AXTab",
            "AXTabGroup",
            "AXToolbar",
            "AXToolbarButton",
            "AXDisclosureTriangle",
            "AXOutlineRow",
            "AXRow",
            "AXCell",
            "AXImage",
            "AXStaticText",
            "AXSearchField",
            "AXSecureTextField",
        ]

        if interactiveRoles.contains(role) {
            return true
        }

        if info["title"] != nil || info["label"] != nil {
            let labelableRoles: Set<String> = [
                "AXGroup",
                "AXList",
                "AXScrollArea",
            ]
            if labelableRoles.contains(role) {
                return true
            }
        }

        return false
    }
}
