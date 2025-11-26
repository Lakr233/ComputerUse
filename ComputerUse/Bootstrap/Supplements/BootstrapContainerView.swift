//
//  BootstrapContainerView.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import SwiftUI

struct BootstrapContainerView<Content: View>: View {
    let content: Content
    let width: CGFloat
    let height: CGFloat

    init(
        width: CGFloat = 600,
        height: CGFloat = 300,
        @ViewBuilder content: () -> Content,
    ) {
        self.width = width
        self.height = height
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Image(.avatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(x: 20, y: 32)
                    .rotationEffect(.degrees(10))
                    .scaleEffect(1.5)
            }
            .frame(width: 180)
            .clipped()
            Divider()
            content
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
        .frame(width: width, height: height, alignment: .center)
    }
}

#Preview {
    BootstrapContainerView {
        VStack {
            Text("Preview Content")
        }
    }
}
