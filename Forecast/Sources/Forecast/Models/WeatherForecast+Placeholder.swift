//
//  WeatherForecast+Placeholder.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

extension WeatherForecast {
    static let placeholder = WeatherForecast(
        current: Current(temperature: 6.0, cloudCover: 85, rainChance: 35, condition: .overcast, isDay: true),
        hours: placeholderHours,
        days: placeholderDays
    )

    private static let placeholderHours: [Hour] = {
        let firstHour = 14
        let temperatures: [Double] = [6.0, 6.0, 5.0, 5.0, 4.0, 4.0, 3.0, 3.0, 3.0, 2.0, 2.0, 2.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 3.0, 4.0, 5.0, 5.0]
        let rainChances = [35, 40, 55, 60, 50, 35, 25, 20, 20, 15, 10, 10, 10, 10, 5, 5, 5, 5, 10, 10, 15, 20, 25, 30]
        let rainyHours = 2...4
        let daylight = 7..<16

        return temperatures.indices.map { index in
            let hour = (firstHour + index) % 24
            return Hour(
                id: "placeholder-\(index)",
                isNow: index == 0,
                hour: String(format: "%02d", hour),
                temperature: temperatures[index],
                rainChance: rainChances[index],
                condition: rainyHours.contains(index) ? .rain : .overcast,
                isDay: daylight.contains(hour)
            )
        }
    }()

    private static let placeholderDays: [Day] = [
        Day(id: "placeholder-0", isToday: true, weekday: "Śr.", minTemperature: 3.0, maxTemperature: 8.0, rainChance: 60, condition: .rain),
        Day(id: "placeholder-1", isToday: false, weekday: "Czw.", minTemperature: 2.0, maxTemperature: 7.0, rainChance: 20, condition: .overcast),
        Day(id: "placeholder-2", isToday: false, weekday: "Pt.", minTemperature: 4.0, maxTemperature: 9.0, rainChance: 70, condition: .rain),
        Day(id: "placeholder-3", isToday: false, weekday: "Sob.", minTemperature: 1.0, maxTemperature: 6.0, rainChance: 10, condition: .partlyCloudy),
        Day(id: "placeholder-4", isToday: false, weekday: "Niedz.", minTemperature: -2.0, maxTemperature: 5.0, rainChance: 0, condition: .clear),
        Day(id: "placeholder-5", isToday: false, weekday: "Pon.", minTemperature: -1.0, maxTemperature: 4.0, rainChance: 10, condition: .partlyCloudy),
        Day(id: "placeholder-6", isToday: false, weekday: "Wt.", minTemperature: 0.0, maxTemperature: 5.0, rainChance: 30, condition: .overcast),
    ]
}
