//
//  HeroSection.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct HeroSection: View {
    private let location: ForecastLocation
    private let current: WeatherForecast.Current
    private let today: WeatherForecast.Day?

    @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize = Typography.displaySize

    init(
        location: ForecastLocation,
        current: WeatherForecast.Current,
        today: WeatherForecast.Day?
    ) {
        self.location = location
        self.current = current
        self.today = today
    }

    var body: some View {
        VStack(spacing: Spacing.xSmall) {
            VStack(spacing: .zero) {
                Text(location.name)
                    .font(Typography.title)
                    .accessibilityAddTraits(.isHeader)
                if !location.subtitle.isEmpty {
                    Text(location.subtitle)
                        .font(Typography.secondary)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            .unredacted()

            Text(TemperatureFormat.string(current.temperature))
                .font(Typography.makeDisplayFont(size: temperatureSize))
                .monospacedDigit()

            Label {
                current.condition.title
            } icon: {
                ConditionSymbol(condition: current.condition, isDay: current.isDay)
            }
            .font(Typography.prominent)

            if let today {
                Localizable.todayTemperatureRange(
                    max: TemperatureFormat.string(today.maxTemperature),
                    min: TemperatureFormat.string(today.minTemperature)
                )
                .font(Typography.secondary)
                .foregroundStyle(Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Padding.xxSmall)
        .accessibilityElement(children: .combine)
    }
}
