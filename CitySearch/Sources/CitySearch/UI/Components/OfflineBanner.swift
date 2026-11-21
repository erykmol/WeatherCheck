//
//  OfflineBanner.swift
//  CitySearch
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
                Localizable.noInternetErrorMessage
                    .font(Typography.footnote)
            }
        } icon: {
            Image(systemName: Constants.offlineIcon)
                .foregroundStyle(Palette.warning)
        }
        .foregroundStyle(Palette.textPrimary)
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let offlineIcon = "wifi.slash"
}
