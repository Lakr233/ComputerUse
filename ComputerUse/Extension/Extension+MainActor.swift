//
//  Extension+MainActor.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import Foundation

extension MainActor {
    nonisolated static func isolated<T: Sendable>(
        _ block: @MainActor @escaping () throws -> (T),
    ) rethrows -> T {
        if Thread.isMainThread {
            try MainActor.assumeIsolated {
                try block()
            }
        } else {
            try DispatchQueue.main.asyncAndWait {
                try block()
            }
        }
    }
}
