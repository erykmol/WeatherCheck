//
//  Localizable.swift
//  Forecast
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import SwiftUI

enum Localizable {
    static var loadingAccessibilityLabel: Text { Text("loading_accessibility_label", bundle: .module) }
    static func todayTemperatureRange(
        max maxTemperature: String,
        min minTemperature: String
    ) -> Text {
        Text("today_temperature_range \(maxTemperature) \(minTemperature)", bundle: .module)
    }

    static var conditionClear: Text { Text("condition_clear", bundle: .module) }
    static var conditionMainlyClear: Text { Text("condition_mainly_clear", bundle: .module) }
    static var conditionPartlyCloudy: Text { Text("condition_partly_cloudy", bundle: .module) }
    static var conditionOvercast: Text { Text("condition_overcast", bundle: .module) }
    static var conditionFog: Text { Text("condition_fog", bundle: .module) }
    static var conditionDrizzle: Text { Text("condition_drizzle", bundle: .module) }
    static var conditionRain: Text { Text("condition_rain", bundle: .module) }
    static var conditionHeavyRain: Text { Text("condition_heavy_rain", bundle: .module) }
    static var conditionSnow: Text { Text("condition_snow", bundle: .module) }
    static var conditionThunderstorm: Text { Text("condition_thunderstorm", bundle: .module) }
    static var conditionUnknown: Text { Text("condition_unknown", bundle: .module) }

    static var cloudCoverTileTitle: Text { Text("cloud_cover_tile_title", bundle: .module) }
    static var cloudCoverLow: Text { Text("cloud_cover_low", bundle: .module) }
    static var cloudCoverModerate: Text { Text("cloud_cover_moderate", bundle: .module) }
    static var cloudCoverHigh: Text { Text("cloud_cover_high", bundle: .module) }
    static var cloudCoverFull: Text { Text("cloud_cover_full", bundle: .module) }

    static var rainChanceTileTitle: Text { Text("rain_chance_tile_title", bundle: .module) }
    static var rainChanceTileCaption: Text { Text("rain_chance_tile_caption", bundle: .module) }

    static var hourlyForecastTitle: Text { Text("hourly_forecast_title", bundle: .module) }
    static var hourlyForecastNow: Text { Text("hourly_forecast_now", bundle: .module) }
    static var dailyForecastTitle: Text { Text("daily_forecast_title", bundle: .module) }
    static var dailyForecastToday: Text { Text("daily_forecast_today", bundle: .module) }

    static var weatherDataAttribution: Text { Text("weather_data_attribution", bundle: .module) }
    static func forecastUpdatedAt(_ date: Date) -> Text {
        Text("forecast_updated_at \(Text(date, format: .dateTime.hour().minute()))", bundle: .module)
    }

    static var noInternetErrorTitle: Text { Text("no_internet_error_title", bundle: .module) }
    static var noInternetErrorMessage: Text { Text("no_internet_error_message", bundle: .module) }
    static var offlineBannerMessage: Text { Text("offline_banner_message", bundle: .module) }

    static var forecastErrorTitle: Text { Text("forecast_error_title", bundle: .module) }
    static var forecastErrorMessage: Text { Text("forecast_error_message", bundle: .module) }
    static func errorDetails(_ details: String) -> Text {
        Text("error_details \(details)", bundle: .module)
    }
    static var retryButton: Text { Text("retry_button", bundle: .module) }
}
