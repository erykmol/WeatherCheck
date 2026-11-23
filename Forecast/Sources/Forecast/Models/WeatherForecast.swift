//
//  WeatherForecast.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct WeatherForecast: Equatable, Sendable {
    struct Current: Equatable, Sendable {
        let temperature: Double
        let cloudCover: Int
        let rainChance: Int?
        let condition: WeatherCondition
        let isDay: Bool
    }

    struct Hour: Equatable, Sendable, Identifiable {
        let id: String
        let isNow: Bool
        let hour: String
        let temperature: Double
        let rainChance: Int?
        let condition: WeatherCondition
        let isDay: Bool
    }

    struct Day: Equatable, Sendable, Identifiable {
        let id: String
        let isToday: Bool
        let weekday: String
        let minTemperature: Double
        let maxTemperature: Double
        let rainChance: Int?
        let condition: WeatherCondition
    }

    let current: Current
    let hours: [Hour]
    let days: [Day]

    var today: Day? {
        days.first
    }

    var temperatureBounds: ClosedRange<Double> {
        guard
            let low = days.map(\.minTemperature).min(),
            let high = days.map(\.maxTemperature).max(),
            low <= high
        else { return 0.0...0.0 }
        return low...high
    }
}
