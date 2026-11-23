//
//  FakeForecastClient.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
@testable import Forecast

actor FakeForecastClient: ForecastClientProtocol {
    private var results: [Result<WeatherForecast, ForecastError>]

    init(results: [Result<WeatherForecast, ForecastError>]) {
        self.results = results
    }

    func fetchForecast(
        latitude: Double,
        longitude: Double
    ) async throws(ForecastError) -> WeatherForecast {
        let result = results.isEmpty ? .failure(.unknown) : results.removeFirst()
        return try result.get()
    }
}
