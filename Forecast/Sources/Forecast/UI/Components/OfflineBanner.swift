//
//  OfflineBanner.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct OfflineBanner: View {
    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: Spacing.xSmall) {
                Localizable.noInternetErrorTitle
                    .font(Typography.secondaryEmphasized)
                Localizable.offlineBannerMessage
                    .font(Typography.footnote)
            }
        } icon: {
            Image(systemName: Constants.offlineIcon)
                .foregroundStyle(Palette.warning)
        }
        .foregroundStyle(Palette.textPrimary)
        .padding(Padding.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.warningBackground, in: RoundedRectangle(cornerRadius: Constants.cornerRadius))
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let offlineIcon = "wifi.slash"
    static let cornerRadius: CGFloat = 14
}
