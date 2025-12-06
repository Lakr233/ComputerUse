//
//  CoordinateConverter.swift
//  ComputerUseKit
//

import AppKit
import CoreGraphics

enum CoordinateConverter {
    static func primaryFrame() -> CGRect? {
        if let main = NSScreen.main {
            return main.frame
        }
        return NSScreen.screens.first?.frame
    }

    static func cocoaToQuartz(_ point: CGPoint, primaryFrame: CGRect? = CoordinateConverter.primaryFrame()) -> CGPoint {
        guard let primaryFrame else { return point }
        return CGPoint(x: point.x, y: primaryFrame.height - point.y)
    }

    static func quartzToCocoa(_ point: CGPoint, primaryFrame: CGRect? = CoordinateConverter.primaryFrame()) -> CGPoint {
        guard let primaryFrame else { return point }
        return CGPoint(x: point.x, y: primaryFrame.height - point.y)
    }

    static func quartzFrameToCocoa(
        _ frame: CGRect,
        primaryFrame: CGRect? = CoordinateConverter.primaryFrame(),
    ) -> CGRect {
        guard let primaryFrame else { return frame }
        let cocoaY = primaryFrame.height - frame.origin.y - frame.height
        return CGRect(
            x: frame.origin.x,
            y: cocoaY,
            width: frame.width,
            height: frame.height,
        )
    }
}
