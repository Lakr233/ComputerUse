//
//  CoordinateConverterTests.swift
//  ComputerUseTests
//

@testable import ComputerUse
import CoreGraphics
import Testing

@Suite("CoordinateConverter Tests")
struct CoordinateConverterTests {
    private let defaultFrame = CGRect(x: 0, y: 0, width: 1920, height: 1080)

    @Test("Cocoa to Quartz flips Y using primary height")
    func cocoaToQuartzUsesPrimaryHeight() {
        let source = CGPoint(x: 100, y: 200)
        let converted = CoordinateConverter.cocoaToQuartz(source, primaryFrame: defaultFrame)
        #expect(Int(converted.x) == 100)
        #expect(Int(converted.y) == 880)
    }

    @Test("Round trip preserves coordinates across screens")
    func roundTripConversionHandlesOffPrimary() {
        let cocoaPoint = CGPoint(x: 120, y: 1280)
        let quartz = CoordinateConverter.cocoaToQuartz(cocoaPoint, primaryFrame: defaultFrame)
        let back = CoordinateConverter.quartzToCocoa(quartz, primaryFrame: defaultFrame)
        #expect(Int(back.x) == 120)
        #expect(Int(back.y) == 1280)
    }

    @Test("Quartz frame converts to Cocoa frame")
    func frameConversionUsesHeight() {
        let primary = CGRect(x: 0, y: 0, width: 2560, height: 1440)
        let quartzFrame = CGRect(x: 100, y: 200, width: 400, height: 250)
        let cocoaFrame = CoordinateConverter.quartzFrameToCocoa(quartzFrame, primaryFrame: primary)

        #expect(Int(cocoaFrame.origin.x) == 100)
        #expect(Int(cocoaFrame.origin.y) == 990)
        #expect(Int(cocoaFrame.width) == 400)
        #expect(Int(cocoaFrame.height) == 250)
    }
}
