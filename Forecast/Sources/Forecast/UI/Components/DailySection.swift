//
//  DailySection.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct DailySection: View {
    private let days: [WeatherForecast.Day]
    private let bounds: ClosedRange<Double>

    init(days: [WeatherForecast.Day], bounds: ClosedRange<Double>) {
        self.days = days
        self.bounds = bounds
    }

    var body: some View {
        CardSection(title: Localizable.dailyForecastTitle, systemImage: Constants.dailyIcon) {
            VStack(spacing: .zero) {
                ForEach(days) { day in
                    DayRow(day: day, bounds: bounds)
                    if day.id != days.last?.id {
                        Divider()
                            .padding(.vertical, Padding.xSmall)
                    }
                }
            }
            .padding(.horizontal, Padding.medium)
        }
    }
}

private enum Constants {
    static let dailyIcon = "calendar"
}
