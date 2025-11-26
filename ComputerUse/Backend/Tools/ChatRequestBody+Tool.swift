//
//  ChatRequestBody+Tool.swift
//  ComputerUseKit
//

import ChatClientKit
import Foundation

public extension ChatRequestBody.Tool {
    var name: String {
        switch self {
        case let .function(name, _, _, _):
            name
        }
    }
}
