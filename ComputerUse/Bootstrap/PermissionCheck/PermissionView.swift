//
//  PermissionView.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import SwiftUI

struct PermissionView: View {
    var body: some View {
        BootstrapContainerView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Welcome to Computer Use")
                    .bold()
                Text("To get you started, we need your permission to take screenshots and perform interactions for you.")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(PermissionButton.Kind.allCases, id: \.self) { kind in
                            PermissionButton(kind: kind)
                        }
                    }
                }
                Text("Click a button above to open System Settings and grant the necessary permissions.")
                    .underline()
                Spacer(minLength: 0)
                HStack {
                    Spacer()
                    Button("Quit") {
                        NSApp.terminate(nil)
                    }
                }
            }
        }
    }
}

#Preview {
    PermissionView()
}
