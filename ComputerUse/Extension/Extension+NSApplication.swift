//
//  Extension+NSApplication.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit

extension NSApplication {
    func restart() {
        let bundlePath = Bundle.main.bundlePath
        let command = "kill -9 \(getpid()); /bin/sleep 1; open -a '\(bundlePath)'"
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", command]
        do {
            try task.run()
        } catch {
            print("failed to restart app \(error.localizedDescription)")
        }
        exit(0)
    }
}
