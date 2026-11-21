//
//  WeatherForecast+Fixtures.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
@testable import Forecast

extension WeatherForecast {
    static let refreshed = WeatherForecast(
        current: Current(temperature: 3, cloudCover: 100, rainChance: 80, condition: .rain, isDay: false),
        hours: [],
        days: []
    )
}
