//
//  ModelConfigurationView.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import SwiftUI

struct ModelConfigurationView: View {
    @State private var viewModel = ModelConfigurationViewModel.shared
    @State private var inputKey: String = ""
    @State private var selectedModel: String = ""
    @State private var availableModels: [String] = []
    @State private var isFetching: Bool = false
    @FocusState private var isFocused: Bool

    init() {
        _inputKey = State(initialValue: ModelConfigurationViewModel.shared.openRouterToken)
        _selectedModel = State(initialValue: ModelConfigurationViewModel.shared.selectedModel)
    }

    var body: some View {
        BootstrapContainerView(width: 600, height: 400) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Model Configuration")
                    .bold()
                Text("Please enter your API key and select a model to continue. Currently we only accept keys from OpenRouter.")

                TextField("Enter your API key", text: $inputKey)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                    .onChange(of: inputKey) { _, _ in
                        availableModels = []
                    }

                if availableModels.isEmpty {
                    Button("Fetch Models") {
                        fetchModels()
                    }
                    .disabled(isFetching)
                } else {
                    List(availableModels, id: \.self, selection: $selectedModel) { model in
                        Text(model)
                            .tag(model)
                    }
                    .listStyle(.plain)
                }

                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                    Button("Save") {
                        saveConfiguration()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear { isFocused = true }
    }

    private var canSave: Bool {
        !inputKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !selectedModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    private func fetchModels() {
        let trimmedKey = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty else {
            availableModels = []
            selectedModel = ""
            return
        }

        let url = URL(string: "https://openrouter.ai/api/v1/models")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        request.setValue("Bearer \(trimmedKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        isFetching = true
        URLSession.shared.dataTask(with: request) { data, _, _ in
            Task { @MainActor in
                isFetching = false

                guard let data else { return }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }

                let models = scrubModel(fromDic: json).sorted()
                availableModels = models

                if !selectedModel.isEmpty, models.contains(selectedModel) {
                    // Keep current selection if it's still available
                } else if !viewModel.selectedModel.isEmpty, models.contains(viewModel.selectedModel) {
                    selectedModel = viewModel.selectedModel
                }
            }
        }.resume()
    }

    private func scrubModel(fromDic dic: Any) -> [String] {
        // Common OpenAI-style: { data: [{id: ""}, ...] }
        if let dict = dic as? [String: Any] {
            if let data = dict["data"] as? [[String: Any]] {
                return data.compactMap { $0["id"] as? String }
            }
            if let data = dict["data"] as? [String] {
                return data
            }
            // Some providers: { models: [ { id/name/model: "..." } ] }
            if let models = dict["models"] as? [[String: Any]] {
                return models.compactMap { item in
                    (item["id"] as? String)
                        ?? (item["name"] as? String)
                        ?? (item["model"] as? String)
                }
            }
            if let models = dict["models"] as? [String] {
                return models
            }
            // Generic container: { items: [...] }
            if let items = dict["items"] as? [[String: Any]] {
                return items.compactMap { $0["id"] as? String ?? $0["name"] as? String }
            }
        }
        // Direct arrays
        if let array = dic as? [[String: Any]] {
            return array.compactMap { $0["id"] as? String ?? $0["name"] as? String }
        }
        if let array = dic as? [String] {
            return array
        }
        return []
    }

    private func saveConfiguration() {
        let trimmedKey = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedModel = selectedModel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKey.isEmpty, !trimmedModel.isEmpty else { return }
        viewModel.openRouterToken = trimmedKey
        viewModel.selectedModel = trimmedModel
        NSApp.restart()
    }
}

#Preview {
    ModelConfigurationView()
}
