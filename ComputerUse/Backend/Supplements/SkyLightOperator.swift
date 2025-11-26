import AppKit

enum SKL_CGSSpaceLevel: Int32 {
    case kCGSSpaceAbsoluteLevelDefault = 0
    case kCGSSpaceAbsoluteLevelSetupAssistant = 100
    case kCGSSpaceAbsoluteLevelSecurityAgent = 200
    case kCGSSpaceAbsoluteLevelScreenLock = 300
    case kSLSSpaceAbsoluteLevelNotificationCenterAtScreenLock = 400
    case kCGSSpaceAbsoluteLevelBootProgress = 500
    case kCGSSpaceAbsoluteLevelVoiceOver = 600
}

@MainActor
class SkyLightOperator {
    let connection: Int32
    let space: Int32

    typealias F_SLSMainConnectionID = @convention(c) () -> Int32
    typealias F_SLSSpaceCreate = @convention(c) (Int32, Int32, Int32) -> Int32
    typealias F_SLSSpaceSetAbsoluteLevel = @convention(c) (Int32, Int32, Int32) -> Int32
    typealias F_SLSShowSpaces = @convention(c) (Int32, CFArray) -> Int32
    typealias F_SLSSpaceAddWindowsAndRemoveFromSpaces = @convention(c) (Int32, Int32, CFArray, Int32) -> Int32

    let SLSMainConnectionID: F_SLSMainConnectionID
    let SLSSpaceCreate: F_SLSSpaceCreate
    let SLSSpaceSetAbsoluteLevel: F_SLSSpaceSetAbsoluteLevel
    let SLSShowSpaces: F_SLSShowSpaces
    let SLSSpaceAddWindowsAndRemoveFromSpaces: F_SLSSpaceAddWindowsAndRemoveFromSpaces

    init(level: SKL_CGSSpaceLevel.RawValue) {
        let handler = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight", RTLD_NOW)
        SLSMainConnectionID = unsafeBitCast(dlsym(handler, "SLSMainConnectionID"), to: F_SLSMainConnectionID.self)
        SLSSpaceCreate = unsafeBitCast(dlsym(handler, "SLSSpaceCreate"), to: F_SLSSpaceCreate.self)
        SLSSpaceSetAbsoluteLevel = unsafeBitCast(dlsym(handler, "SLSSpaceSetAbsoluteLevel"), to: F_SLSSpaceSetAbsoluteLevel.self)
        SLSShowSpaces = unsafeBitCast(dlsym(handler, "SLSShowSpaces"), to: F_SLSShowSpaces.self)
        SLSSpaceAddWindowsAndRemoveFromSpaces = unsafeBitCast(dlsym(handler, "SLSSpaceAddWindowsAndRemoveFromSpaces"), to: F_SLSSpaceAddWindowsAndRemoveFromSpaces.self)

        connection = SLSMainConnectionID()
        space = SLSSpaceCreate(connection, 1, 0)
        _ = SLSSpaceSetAbsoluteLevel(
            connection,
            space,
            level,
        )
        _ = SLSShowSpaces(connection, [space] as CFArray)
    }

    convenience init(level: SKL_CGSSpaceLevel, offsetAdding offset: SKL_CGSSpaceLevel.RawValue = 0) {
        self.init(level: level.rawValue + offset)
    }

    func delegateWindow(_ window: NSWindow) {
        _ = SLSSpaceAddWindowsAndRemoveFromSpaces(
            connection,
            space,
            [window.windowNumber] as CFArray,
            7,
        )
    }
}
