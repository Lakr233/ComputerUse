//
//  ConsentHandler.swift
//  ComputerUseKit
//

import Foundation

public typealias ConsentHandler = @Sendable (ExecutionStep) async throws -> Bool
