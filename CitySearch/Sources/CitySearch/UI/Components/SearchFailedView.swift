//
//  SearchFailedView.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct SearchFailedView: View {
    private let message: String?
    private let onRetry: () -> Void

    init(message: String?, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: Spacing.xSmall) {
                        Localizable.searchErrorTitle
                            .font(Typography.headline)
                        Localizable.searchErrorMessage
                            .font(Typography.secondary)
                            .foregroundStyle(Palette.textSecondary)
                        if let message {
                            Localizable.errorDetails(message)
                                .font(Typography.footnote)
                                .foregroundStyle(Palette.textSecondary)
                        }
                    }
                } icon: {
                    Image(systemName: Constants.failedIcon)
                        .foregroundStyle(Palette.warning)
                }
                .accessibilityElement(children: .combine)

                Button {
                    onRetry()
                } label: {
                    Localizable.retryButton
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private enum Constants {
    static let failedIcon = "exclamationmark.triangle"
}
