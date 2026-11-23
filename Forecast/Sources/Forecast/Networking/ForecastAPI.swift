//
//  ForecastAPI.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

struct ForecastAPI: ForecastAPIProtocol {
    static let baseURL = URL(staticString: "https://api.open-meteo.com/")

    func forecast(latitude: Double, longitude: Double) -> Endpoint {
        Endpoint(
            method: .GET,
            path: "v1/forecast",
            query: [
                URLQueryItem(name: "latitude", value: String(latitude)),
                URLQueryItem(name: "longitude", value: String(longitude)),
                URLQueryItem(name: "current", value: "temperature_2m,cloud_cover,weather_code,is_day"),
                URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weather_code,is_day"),
                URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "forecast_days", value: String(Constants.forecastDays)),
            ]
        )
    }
}

private enum Constants {
    static let forecastDays = 7
}
