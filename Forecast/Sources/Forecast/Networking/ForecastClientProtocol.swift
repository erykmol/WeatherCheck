//
//  ForecastClientProtocol.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

protocol ForecastClientProtocol: Sendable {
    func forecast(latitude: Double, longitude: Double) async throws(ForecastError) -> WeatherForecast
}
