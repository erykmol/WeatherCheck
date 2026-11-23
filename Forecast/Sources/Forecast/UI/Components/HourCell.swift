//
//  HourCell.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct HourCell: View {
    private let hour: WeatherForecast.Hour

    init(hour: WeatherForecast.Hour) {
        self.hour = hour
    }

    var body: some View {
        VStack(spacing: Spacing.small) {
            Group {
                if hour.isNow {
                    Localizable.hourlyForecastNow
                } else {
                    Text(hour.hour)
                }
            }
            .font(Typography.secondaryEmphasized)

            ConditionSymbol(condition: hour.condition, isDay: hour.isDay)
                .font(Typography.largeIcon)
                .frame(height: Constants.hourIconHeight)

            Group {
                if let rainChance = hour.rainChance {
                    Text(rainChance, format: .percent)
                } else {
                    Text(verbatim: Constants.missingValue)
                }
            }
            .font(Typography.label)
            .foregroundStyle(Palette.rain)

            Text(TemperatureFormat.string(hour.temperature))
                .font(Typography.headline)
                .monospacedDigit()
        }
        .frame(minWidth: Constants.hourCellWidth)
        .accessibilityElement(children: .combine)
    }
}

private enum Constants {
    static let hourCellWidth: CGFloat = 48.0
    static let hourIconHeight: CGFloat = 28.0

    static let missingValue = "–"
}
