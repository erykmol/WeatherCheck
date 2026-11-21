//
//  MetricTile.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct MetricTile: View {
    private let title: Text
    private let systemImage: String
    private let percent: Int?
    private let caption: Text
    private let tint: Color

    init(title: Text, systemImage: String, percent: Int?, caption: Text, tint: Color) {
        self.title = title
        self.systemImage = systemImage
        self.percent = percent
        self.caption = caption
        self.tint = tint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Label {
                title
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScaleFactor)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }
            .font(Typography.label)
            .textCase(.uppercase)
            .foregroundStyle(Palette.textSecondary)

            Group {
                if let percent {
                    Text(percent, format: .percent)
                } else {
                    Text(verbatim: Constants.missingValue)
                }
            }
            .font(Typography.metric)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: Spacing.small) {
                caption
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScaleFactor)
                    .font(Typography.footnote)
                    .foregroundStyle(Palette.textSecondary)

                ProgressView(value: Double(percent ?? 0), total: Constants.percentTotal)
                    .tint(tint)
                    .accessibilityHidden(true)
            }
        }
        .padding(Padding.medium)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let percentTotal: Double = 100
    static let cardCornerRadius: CGFloat = 14
    static let missingValue = "–"
    static let minimumScaleFactor: CGFloat = 0.5
}
