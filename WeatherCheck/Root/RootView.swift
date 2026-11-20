//
//  RootView.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem
import CitySearch

struct RootView: View {
    private let history: any SearchHistoryStoring

    init(history: any SearchHistoryStoring) {
        self.history = history
    }

    var body: some View {
        NavigationStack {
            CitySearchView(history: history, onCitySelected: { _ in })
        }
        .tint(Palette.accent)
        .environment(\.locale, Locale(identifier: "pl_PL"))
    }
}
