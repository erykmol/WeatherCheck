//
//  ForecastClientProtocol.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

protocol ForecastClientProtocol: Sendable {
    func fetchForecast(
        latitude: Double,
        longitude: Double
    ) async throws(ForecastError) -> WeatherForecast
}
