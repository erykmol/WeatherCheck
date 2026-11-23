//
//  CardSection.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct CardSection<Content: View>: View {
    private let title: Text
    private let systemImage: String
    private let content: Content

    init(
        title: Text,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.large) {
            Label {
                title
            } icon: {
                Image(systemName: systemImage)
            }
            .font(Typography.label)
            .textCase(.uppercase)
            .foregroundStyle(Palette.textSecondary)
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, Padding.medium)

            Divider()
                .padding(.horizontal, Padding.medium)

            content
        }
        .padding(.vertical, Padding.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
    }
}

private enum Constants {
    static let cardCornerRadius: CGFloat = 14.0
}
