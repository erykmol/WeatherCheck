//
//  WeatherForecastTests.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
@testable import Forecast

struct WeatherForecastTests {
    private func makeSUT(days: [WeatherForecast.Day]) -> WeatherForecast {
        WeatherForecast(
            current: WeatherForecast.Current(temperature: 6.0, cloudCover: 85, rainChance: 35, condition: .overcast, isDay: true),
            hours: [],
            days: days
        )
    }

    private func makeDay(
        _ id: String,
        min: Double,
        max: Double
    ) -> WeatherForecast.Day {
        WeatherForecast.Day(
            id: id,
            isToday: false,
            weekday: id,
            minTemperature: min,
            maxTemperature: max,
            rainChance: nil,
            condition: .overcast
        )
    }

    @Test func todayIsTheFirstDay() {
        let sut = makeSUT(days: [makeDay("2026-11-18", min: 3.0, max: 8.0), makeDay("2026-11-19", min: 2.0, max: 7.0)])

        #expect(sut.today?.id == "2026-11-18")
    }

    @Test func boundsCoverTheWholeWeek() {
        let sut = makeSUT(days: [makeDay("2026-11-18", min: 3.1, max: 8.2), makeDay("2026-11-19", min: -1.6, max: 7.0)])

        #expect(sut.temperatureBounds == -1.6...8.2)
    }

    @Test func hasNoTodayOrRangeWithoutDays() {
        let sut = makeSUT(days: [])

        #expect(sut.today == nil)
        #expect(sut.temperatureBounds == 0.0...0.0)
    }
}
