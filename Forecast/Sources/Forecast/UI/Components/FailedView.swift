//
//  FailedView.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct FailedView: View {
    private let message: String?
    private let onRetry: () -> Void

    init(message: String?, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.forecastErrorTitle
            } icon: {
                Image(systemName: Constants.failedIcon)
            }
        } description: {
            VStack(spacing: Spacing.medium) {
                Localizable.forecastErrorMessage
                if let message {
                    Localizable.errorDetails(message)
                        .font(Typography.footnote)
                }
            }
        } actions: {
            RetryButton(action: onRetry)
        }
    }
}

private enum Constants {
    static let failedIcon = "exclamationmark.triangle"
}
