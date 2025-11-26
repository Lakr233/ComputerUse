//
//  Tools.swift
//  ComputerUseKit
//
//  Aggregates all tool definitions by category.
//

import ChatClientKit
import Foundation

public enum Tools {
    public static let screen: [ChatRequestBody.Tool] = [
        ScreenTools.screenReadContent,
    ]

    public static let application: [ChatRequestBody.Tool] = [
        ScreenTools.applicationReadList,
        ScreenTools.applicationExecuteOpen,
        ScreenTools.applicationExecuteTerminate,
    ]

    public static let pointer: [ChatRequestBody.Tool] = [
        PointerTools.pointerReadLocation,
        PointerTools.pointerExecuteSequence,
    ]

    public static let keyboard: [ChatRequestBody.Tool] = [
        KeyboardTools.keyboardExecuteSequence,
        KeyboardTools.keyboardExecuteInput,
    ]

    public static let all: [ChatRequestBody.Tool] = [
        screen,
        application,
        pointer,
        keyboard,
    ].flatMap(\.self)
}
