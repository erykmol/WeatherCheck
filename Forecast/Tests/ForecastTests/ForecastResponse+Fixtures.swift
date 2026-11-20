//
//  ForecastResponse+Fixtures.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
@testable import Forecast

extension ForecastResponse {
    static func fixture(
        currentTime: String = "2026-11-18T14:30",
        hourCount: Int = 48,
        temperatures: [Double?]? = nil,
        rainChances: [Double?]? = nil,
        hourlyWeatherCodes: [Int?]? = nil,
        dailyLows: [Double?] = [3.1, -1.6],
        dailyHighs: [Double?] = [8.2, 7.0]
    ) -> ForecastResponse {
        let hours = 0..<hourCount
        let times = hours.map { offset in
            String(format: "2026-11-%02dT%02d:00", 18 + offset / 24, offset % 24)
        }
        return ForecastResponse(
            current: Current(time: currentTime, temperature: 6.4, cloudCover: 85, weatherCode: 3, isDay: 1),
            hourly: Hourly(
                time: times,
                temperature: temperatures ?? hours.map { Double($0) / 10 },
                precipitationProbability: rainChances ?? hours.map { Double($0) },
                weatherCode: hourlyWeatherCodes ?? hours.map { _ in 61 },
                isDay: hours.map { _ in 1 }
            ),
            daily: Daily(
                time: ["2026-11-18", "2026-11-19"],
                weatherCode: [61, 3],
                temperatureMax: dailyHighs,
                temperatureMin: dailyLows,
                precipitationProbabilityMax: [60, 20]
            )
        )
    }
}
