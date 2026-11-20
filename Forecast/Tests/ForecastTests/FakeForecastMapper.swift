//
//  FakeForecastMapper.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import os
@testable import Forecast

final class FakeForecastMapper: ForecastMapperProtocol {
    private let result: Result<WeatherForecast, ForecastError>
    private let responses = OSAllocatedUnfairLock<[ForecastResponse]>(initialState: [])

    init(result: Result<WeatherForecast, ForecastError>) {
        self.result = result
    }

    var receivedResponses: [ForecastResponse] {
        responses.withLock { $0 }
    }

    func forecast(from response: ForecastResponse) throws(ForecastError) -> WeatherForecast {
        responses.withLock { $0.append(response) }
        return try result.get()
    }
}
