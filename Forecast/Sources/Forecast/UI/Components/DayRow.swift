//
//  DayRow.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct DayRow: View {
    private let day: WeatherForecast.Day
    private let bounds: ClosedRange<Double>

    init(day: WeatherForecast.Day, bounds: ClosedRange<Double>) {
        self.day = day
        self.bounds = bounds
    }

    var body: some View {
        HStack(spacing: Spacing.medium) {
            Group {
                if day.isToday {
                    Localizable.dailyForecastToday
                } else {
                    Text(day.weekday)
                }
            }
            .font(Typography.label)
            .lineLimit(1)
            .frame(width: Constants.weekdayWidth, alignment: .leading)

            VStack(spacing: Spacing.xxSmall) {
                Image(systemName: day.condition.symbolName(isDay: true))
                    .symbolRenderingMode(.multicolor)
                if let rainChance = day.rainChance {
                    Text(rainChance, format: .percent)
                        .font(Typography.smallLabel)
                        .foregroundStyle(Palette.rain)
                }
            }
            .frame(width: Constants.dayIconWidth)

            Text(TemperatureFormat.string(day.minTemperature))
                .foregroundStyle(Palette.textSecondary)
                .frame(width: Constants.temperatureWidth, alignment: .trailing)

            TemperatureRangeBar(range: day.minTemperature...day.maxTemperature, bounds: bounds)

            Text(TemperatureFormat.string(day.maxTemperature))
                .frame(width: Constants.temperatureWidth, alignment: .trailing)
        }
        .monospacedDigit()
        .frame(minHeight: Constants.dayRowHeight)
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let dayRowHeight: CGFloat = 52
    static let dayIconWidth: CGFloat = 40
    static let weekdayWidth: CGFloat = 56
    static let temperatureWidth: CGFloat = 36
}
