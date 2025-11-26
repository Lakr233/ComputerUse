//
//  ApplicationService+Searching.swift
//  ComputerUseKit
//

import Foundation

extension ApplicationService {
    func urlForApplication(named name: String) -> URL? {
        let fileManager = FileManager.default
        let candidateNames: [String] = name.hasSuffix(".app") ? [name] : ["\(name).app", name]
        let searchDirectories: [URL] = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/Applications/Utilities"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/System/Applications/Utilities"),
            fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Applications"),
        ]

        for directory in searchDirectories {
            for candidate in candidateNames {
                let candidateURL = directory.appendingPathComponent(candidate)
                if fileManager.fileExists(atPath: candidateURL.path) {
                    return candidateURL
                }
            }
            if let found = findApplication(named: candidateNames, in: directory, maxDepth: 2) {
                return found
            }
        }

        return nil
    }

    private func findApplication(named candidates: [String], in directory: URL, maxDepth: Int) -> URL? {
        let rootComponents = directory.standardizedFileURL.pathComponents.count
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles],
        ) else { return nil }

        for case let url as URL in enumerator {
            let depth = url.standardizedFileURL.pathComponents.count - rootComponents
            if depth > maxDepth {
                enumerator.skipDescendants()
                continue
            }
            if candidates.contains(url.lastPathComponent) {
                return url
            }
        }

        return nil
    }
}
