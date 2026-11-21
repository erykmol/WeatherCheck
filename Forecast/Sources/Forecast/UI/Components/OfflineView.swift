//
//  OfflineView.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI

struct OfflineView: View {
    private let onRetry: () -> Void

    init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.noInternetErrorTitle
            } icon: {
                Image(systemName: Constants.offlineIcon)
            }
        } description: {
            Localizable.noInternetErrorMessage
        } actions: {
            RetryButton(action: onRetry)
        }
    }
}

private enum Constants {
    static let offlineIcon = "wifi.slash"
}
