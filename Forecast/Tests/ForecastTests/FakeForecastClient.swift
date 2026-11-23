//
//  FakeForecastClient.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
@testable import Forecast

actor FakeForecastClient: ForecastClientProtocol {
    struct Request: Equatable, Sendable {
        let latitude: Double
        let longitude: Double
        let ignoringCache: Bool
    }

    private var results: [Result<WeatherForecast, ForecastError>]
    private(set) var receivedRequests: [Request] = []

    init(results: [Result<WeatherForecast, ForecastError>]) {
        self.results = results
    }

    func fetchForecast(
        latitude: Double,
        longitude: Double,
        ignoringCache: Bool
    ) async throws(ForecastError) -> WeatherForecast {
        receivedRequests.append(Request(latitude: latitude, longitude: longitude, ignoringCache: ignoringCache))
        let result = results.isEmpty ? .failure(.unknown) : results.removeFirst()
        return try result.get()
    }
}
