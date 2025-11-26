//
//  Extension+NSScreen.swift
//  ComputerUse
//
//  Created by qaq on 2/12/2025.
//

import AppKit

extension NSScreen: @retroactive Identifiable {
    public var id: Int {
        let item = deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
        let value = item as? NSNumber
        return value?.intValue ?? 0
    }
}
