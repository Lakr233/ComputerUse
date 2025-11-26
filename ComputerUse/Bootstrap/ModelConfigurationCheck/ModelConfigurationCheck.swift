//
//  ModelConfigurationCheck.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class ModelConfigurationViewModel {
    nonisolated static let shared = MainActor.isolated { ModelConfigurationViewModel() }

    private let openRouterTokenKey = "wiki.qaq.cu.openrouter.token"
    private let selectedModelKey = "wiki.qaq.cu.selected.model"

    var openRouterToken: String {
        get {
            UserDefaults.standard.string(forKey: openRouterTokenKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: openRouterTokenKey)
        }
    }

    var selectedModel: String {
        get {
            UserDefaults.standard.string(forKey: selectedModelKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: selectedModelKey)
        }
    }

    var hasApiKey: Bool {
        !openRouterToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasSelectedModel: Bool {
        !selectedModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isConfigured: Bool {
        hasApiKey && hasSelectedModel
    }

    private init() {}
}

@MainActor
enum ModelConfigurationCheck {
    static var isConfigured: Bool {
        ModelConfigurationViewModel.shared.isConfigured
    }

    static var openRouterToken: String {
        ModelConfigurationViewModel.shared.openRouterToken
    }

    static var selectedModel: String {
        ModelConfigurationViewModel.shared.selectedModel
    }

    static func requiresInteraction() -> Bool {
        !isConfigured
    }

    static func prompt() -> Never {
        ModelConfigurationUI.main()
        fatalError()
    }
}
