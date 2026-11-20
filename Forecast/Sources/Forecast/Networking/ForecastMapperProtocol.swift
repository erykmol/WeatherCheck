//
//  ForecastMapperProtocol.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

protocol ForecastMapperProtocol: Sendable {
    func forecast(from response: ForecastResponse) throws(ForecastError) -> WeatherForecast
}
