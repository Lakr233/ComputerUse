//
//  ScreenSelectorView.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import AppKit
import SwiftUI

struct ScreenSelectorView: View {
    @State private var viewModel = ScreenSelectorViewModel.shared
    @State private var selectedScreenId: Int? = nil
    @FocusState private var isFocused: Bool

    private var availableScreens: [NSScreen] {
        NSScreen.screens
    }

    var body: some View {
        BootstrapContainerView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Working Screen")
                    .bold()
                Text("Please select a screen to use as your working screen.")
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(availableScreens, id: \.id) { screen in
                                ScreenOptionView(
                                    screen: screen,
                                    isSelected: selectedScreenId == screen.id,
                                ) {
                                    selectedScreenId = screen.id
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                    Button("Save") {
                        saveScreen()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedScreenId == nil)
                }
            }
        }
        .onAppear {
            selectedScreenId = viewModel.workingScreenId
            if selectedScreenId == nil, let mainScreen = NSScreen.main {
                selectedScreenId = mainScreen.id
            }
            isFocused = true
        }
    }

    private func saveScreen() {
        let screenId = selectedScreenId ?? NSScreen.main!.id
        viewModel.workingScreenId = screenId
        NSApp.restart()
    }
}

struct ScreenOptionView: View {
    let screen: NSScreen
    let isSelected: Bool
    let onSelect: () -> Void

    private var screenDescription: String {
        let frame = screen.frame
        let mainScreen = NSScreen.main
        let isMain = screen == mainScreen
        let size = "\(Int(frame.width))×\(Int(frame.height))"
        return isMain ? "Main Screen (\(size))" : "Screen \(screen.id) (\(size))"
    }

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .accent : .secondary)
                Text(screenDescription)
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accent.opacity(0.1) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    ScreenSelectorView()
}
