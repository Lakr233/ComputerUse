//
//  ApplicationService+Opening.swift
//  ComputerUseKit
//

import AppKit
import Foundation

extension ApplicationService {
    func open(_ input: ApplicationOpenInput) async throws {
        let workspace = NSWorkspace.shared
        if let bundleId = input.bundleIdentifier {
            if let appURL = workspace.urlForApplication(withBundleIdentifier: bundleId) {
                try await openApplication(at: appURL, workspace: workspace)
                return
            }
        }
        if let path = input.path {
            try await openApplication(at: URL(fileURLWithPath: path), workspace: workspace)
            return
        }
        if let name = input.name {
            if let running = workspace.runningApplications.first(where: { $0.localizedName == name }) {
                running.activate(options: .activateAllWindows)
                return
            }
            if let appURL = urlForApplication(named: name) {
                try await openApplication(at: appURL, workspace: workspace)
                return
            }
        }
        throw ToolExecutionError.applicationNotFound
    }

    private func openApplication(at url: URL, workspace: NSWorkspace) async throws {
        let configuration = NSWorkspace.OpenConfiguration()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            workspace.openApplication(at: url, configuration: configuration) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
