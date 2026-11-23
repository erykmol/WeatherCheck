//
//  CityRow.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct CityRow: View {
    private let title: AttributedString
    private let subtitle: String
    private let systemImage: String

    init(
        title: AttributedString,
        subtitle: String,
        systemImage: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: Spacing.xLarge) {
            Image(systemName: systemImage)
                .font(Typography.icon)
                .foregroundStyle(Palette.textSecondary)
                .frame(width: Constants.rowIconWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                Text(title)
                    .foregroundStyle(Palette.textPrimary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(Typography.secondary)
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            Spacer()

            Image(systemName: Constants.chevronIcon)
                .font(Typography.accessory)
                .foregroundStyle(Palette.lightGray)
                .accessibilityHidden(true)
        }
        .padding(.vertical, Padding.xxSmall)
        .contentShape(Rectangle())
    }
}

private enum Constants {
    static let rowIconWidth: CGFloat = 28.0
    static let chevronIcon = "chevron.right"
}
