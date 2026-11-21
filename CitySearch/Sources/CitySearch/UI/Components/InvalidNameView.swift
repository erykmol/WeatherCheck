//
//  InvalidNameView.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct InvalidNameView: View {
    private let message: Text

    init(message: Text) {
        self.message = message
    }

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        Localizable.invalidNameErrorTitle
                            .font(Typography.headline)
                        message
                            .font(Typography.secondary)
                            .foregroundStyle(Palette.textSecondary)
                    }
                } icon: {
                    Image(systemName: Constants.invalidIcon)
                        .foregroundStyle(Palette.destructive)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum Constants {
    static let invalidIcon = "exclamationmark.circle"
}
