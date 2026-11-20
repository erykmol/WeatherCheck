//
//  RootView.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import Navigation
import DesignSystem
import CitySearch
import Forecast

struct RootView: View {
    @State private var navigation = NavigationStore<Destination>()
    private let history: any SearchHistoryStoring

    init(history: any SearchHistoryStoring) {
        self.history = history
    }

    var body: some View {
        NavigationContainer(navigation) {
            CitySearchView(history: history, onCitySelected: { navigation.show(.forecast($0)) })
        } screen: { destination in
            switch destination {
            case .forecast(let city):
                ForecastView(location: ForecastLocation(city))
            }
        }
        .tint(Palette.accent)
        .environment(\.locale, Locale(identifier: "pl_PL"))
    }
}
