//
//  ControlPanelContentView.swift
//  ComputerUse
//
//  Created by qaq on 3/12/2025.
//

import SwiftUI

struct ControlPanelContentView: View {
    @StateObject var workflow: Workflow
    @State var opening = true

    init(workflow: Workflow) {
        _workflow = .init(wrappedValue: workflow)
    }

    var title: String {
        workflow.title.isEmpty ? "Computer Use" : workflow.title
    }

    var body: some View {
        ZStack {
            Spacer()
            if !opening {
                content
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .animation(.spring, value: opening)
        .animation(.interactiveSpring, value: workflow.title)
        .animation(.interactiveSpring, value: workflow.isRunning)
        .animation(.interactiveSpring, value: workflow.streamText)
        .onAppear { if opening { opening.toggle() }}
    }

    var content: some View {
        VStack(spacing: 12) {
            header
            Divider().padding(.horizontal, -32)
            if workflow.isRunning {
                control
                    .transition(.opacity)
            } else {
                field
                    .transition(.opacity)
            }
            if !workflow.streamText.isEmpty {
                Divider().padding(.horizontal, -32)
                    .transition(.opacity)
                status
                    .transition(.opacity)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contentShape(Rectangle())
        .padding()
    }

    var header: some View {
        Text(title)
            .contentTransition(.numericText())
            .bold()
            .animation(.interactiveSpring, value: title)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var status: some View {
        ScrollViewReader { r in
            ScrollView(showsIndicators: false) {
                VStack {
                    Text(workflow.streamText.isEmpty ? "Thinking..." : workflow.streamText)
                        .font(.footnote)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                        .hidden()
                        .id("bottom")
                }
                .onChange(of: workflow.streamText) { _, _ in
                    withAnimation(.interactiveSpring) {
                        r.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
        }
        .frame(height: 100)
    }

    var control: some View {
        HStack {
            Text("Working on it...")
                .font(.footnote)
            Spacer(minLength: 0)
            Button {
                workflow.cancel()
            } label: {
                Image(systemName: "pause.fill")
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    var field: some View {
        TextField("What you gonna let us do?", text: $workflow.editorText)
            .textFieldStyle(.plain)
            .padding(4)
            .background(.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onSubmit {
                workflow.submit()
            }
    }
}
