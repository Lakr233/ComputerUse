//
//  ApplicationService.swift
//  ComputerUseKit
//

import AppKit
import Foundation

struct ApplicationService {
    func listRunningApps() -> [ApplicationInfo] {
        let privateFrameworksPath = "/System/Library/PrivateFrameworks/"

        return NSWorkspace.shared.runningApplications.compactMap { app in
            let path = app.bundleURL?.path
            if let path, path.hasPrefix(privateFrameworksPath) {
                return nil
            }
            return ApplicationInfo(
                name: app.localizedName,
                bundleIdentifier: app.bundleIdentifier,
                path: path,
                running: true,
                processId: app.processIdentifier,
            )
        }
    }

    func terminate(_ input: ApplicationTerminateInput) throws {
        let workspace = NSWorkspace.shared
        let match: NSRunningApplication? = if let bundleId = input.bundleIdentifier {
            NSRunningApplication.runningApplications(withBundleIdentifier: bundleId).first
        } else if let name = input.name {
            workspace.runningApplications.first { $0.localizedName == name }
        } else if let path = input.path {
            workspace.runningApplications.first { $0.bundleURL?.path == path }
        } else {
            nil
        }
        guard let app = match else {
            throw ToolExecutionError.applicationNotFound
        }
        if input.force == true {
            app.forceTerminate()
        } else {
            app.terminate()
        }
    }
}
