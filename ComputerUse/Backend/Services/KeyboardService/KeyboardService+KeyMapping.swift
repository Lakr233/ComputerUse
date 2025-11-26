//
//  KeyboardService+KeyMapping.swift
//  ComputerUseKit
//

import ApplicationServices
import Carbon.HIToolbox.Events

extension KeyboardService {
    func keyCode(for key: String?) throws -> CGKeyCode {
        guard let key else { throw ToolExecutionError.keyMappingFailed("Missing key") }
        let normalized = RelaxedCoding.normalize(key)
        if let code = CarbonKeys.keyCode(forNormalized: normalized) {
            return code
        }
        throw ToolExecutionError.keyMappingFailed("Unsupported key \(key)")
    }
}
