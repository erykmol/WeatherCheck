//
//  AttributionFooter.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct AttributionFooter: View {
    private let updatedAt: Date?

    init(updatedAt: Date?) {
        self.updatedAt = updatedAt
    }

    var body: some View {
        VStack(spacing: Spacing.xxSmall) {
            Localizable.weatherDataAttribution
            if let updatedAt {
                Localizable.forecastUpdatedAt(updatedAt)
            }
        }
        .font(Typography.footnote)
        .foregroundStyle(Palette.textSecondary)
        .tint(Palette.accent)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}
