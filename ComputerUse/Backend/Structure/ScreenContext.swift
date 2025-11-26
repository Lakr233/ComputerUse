//
//  ScreenContext.swift
//  ComputerUseKit
//

import CoreGraphics
import Foundation

public struct ScreenContext: Sendable {
    public let screenshotBase64: String
    public let screenshotMediaType: String
    public let pointerLocation: PointerLocation
    public let pointerScreenNumber: String
    public let activeApplication: ActiveApplication?
}
