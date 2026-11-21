//
//  ForecastContent.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct ForecastContent: View {
    private let location: ForecastLocation
    private let forecast: WeatherForecast
    private let updatedAt: Date?
    private let isOffline: Bool

    init(location: ForecastLocation, forecast: WeatherForecast, updatedAt: Date?, isOffline: Bool) {
        self.location = location
        self.forecast = forecast
        self.updatedAt = updatedAt
        self.isOffline = isOffline
    }

    var body: some View {
        VStack(spacing: Spacing.xxLarge) {
            if isOffline {
                OfflineBanner()
            }
            HeroSection(location: location, current: forecast.current, today: forecast.today)
            MetricTiles(current: forecast.current)
            HourlySection(hours: forecast.hours)
            DailySection(days: forecast.days, bounds: forecast.temperatureBounds)
            AttributionFooter(updatedAt: updatedAt)
        }
        .padding(.horizontal, Padding.medium)
        .padding(.bottom, Padding.large)
    }
}
