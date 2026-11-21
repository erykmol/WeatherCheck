//
//  HourlySection.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct HourlySection: View {
    private let hours: [WeatherForecast.Hour]

    init(hours: [WeatherForecast.Hour]) {
        self.hours = hours
    }

    var body: some View {
        CardSection(title: Localizable.hourlyForecastTitle, systemImage: Constants.hourlyIcon) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: Spacing.xSmall) {
                    ForEach(hours) { hour in
                        HourCell(hour: hour)
                    }
                }
                .padding(.horizontal, Padding.medium)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private enum Constants {
    static let hourlyIcon = "clock"
}
