//
//  PermissionButton.swift
//  ComputerUse
//
//  Created by qaq on 26/11/2025.
//

import SwiftUI

struct PermissionButton: View {
    enum Kind: CaseIterable {
        case accessibility
        case screenRecording

        var image: String {
            switch self {
            case .accessibility: "accessibility.fill"
            case .screenRecording: "inset.filled.rectangle.and.person.filled.circle.fill"
            }
        }

        var title: LocalizedStringKey {
            switch self {
            case .accessibility: "Accessibility"
            case .screenRecording: "Screen Recording"
            }
        }

        var isGranted: Bool {
            switch self {
            case .accessibility: PermissionCheck.isAccessibilityTrusted
            case .screenRecording: PermissionCheck.isScreenCaptureAuthorized
            }
        }

        func prompt() {
            switch self {
            case .accessibility: PermissionCheck.promptAccessibilityDialog()
            case .screenRecording: PermissionCheck.promptScreenCaptureDialog()
            }
        }
    }

    let kind: Kind

    init(kind: Kind) {
        self.kind = kind
    }

    var body: some View {
        ZStack {
            Image(systemName: kind.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32, alignment: .center)
                .foregroundStyle(.white)
        }
        .frame(width: 80, height: 80, alignment: .center)
        .background(kind.isGranted ? Color.accent : Color.gray)
        .contentShape(Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .onTapGesture {
            kind.prompt()
        }
    }
}
