//
//  ForecastMapperTests.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
@testable import Forecast

struct ForecastMapperTests {
    @Test func startsTheHoursAtTheCurrentHour() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture())

        #expect(forecast.hours.count == 24)
        #expect(forecast.hours.first?.id == "2026-11-18T14:00")
        #expect(forecast.hours.first?.isNow == true)
        #expect(forecast.hours.first?.hour == "14")
        #expect(forecast.hours.dropFirst().first?.hour == "15")
        #expect(forecast.hours.last?.id == "2026-11-19T13:00")
    }

    @Test func endsTheHoursWhereTheDataEnds() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(hourCount: 30))

        #expect(forecast.hours.count == 16)
        #expect(forecast.hours.last?.id == "2026-11-19T05:00")
    }

    @Test func takesTheCurrentChanceOfRainFromTheCurrentHour() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture())

        #expect(forecast.current.rainChance == 14)
    }

    @Test func takesTheRestOfTheCurrentWeatherFromTheCurrentConditions() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture())

        #expect(forecast.current.temperature == 6.4)
        #expect(forecast.current.cloudCover == 85)
        #expect(forecast.current.condition == .overcast)
        #expect(forecast.current.isDay)
    }

    @Test func skipsHoursWithoutATemperature() throws {
        var temperatures: [Double?] = (0..<48).map { Double($0) / 10.0 }
        temperatures[15] = nil
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(temperatures: temperatures))

        #expect(forecast.hours.count == 23)
        #expect(forecast.hours.dropFirst().first?.hour == "16")
    }

    @Test func leavesTheChanceOfRainEmptyWhenItIsMissing() throws {
        var rainChances: [Double?] = (0..<48).map { Double($0) }
        rainChances[15] = nil
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(rainChances: rainChances))

        #expect(forecast.hours.first?.rainChance == 14)
        #expect(forecast.hours.dropFirst().first?.rainChance == nil)
    }

    @Test func usesAnUnknownConditionWhenTheCodeIsMissing() throws {
        var weatherCodes: [Int?] = (0..<48).map { _ in 61 }
        weatherCodes[14] = nil
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(hourlyWeatherCodes: weatherCodes))

        #expect(forecast.hours.first?.condition == .unknown)
        #expect(forecast.hours.dropFirst().first?.condition == .rain)
    }

    @Test func labelsTodayAndPolishWeekdays() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture())

        #expect(forecast.days.count == 2)
        #expect(forecast.days.first?.isToday == true)
        #expect(forecast.days.last?.isToday == false)
        #expect(forecast.days.last?.weekday == "Czw.")
    }

    @Test func skipsDaysWithoutATemperature() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(dailyLows: [3.1, nil]))

        #expect(forecast.days.map(\.id) == ["2026-11-18"])
    }

    @Test func putsTheLowerTemperatureFirst() throws {
        let sut = ForecastMapper()

        let forecast = try sut.forecast(from: .fixture(dailyLows: [8.2, -1.6], dailyHighs: [3.1, 7.0]))

        #expect(forecast.days.first?.minTemperature == 3.1)
        #expect(forecast.days.first?.maxTemperature == 8.2)
    }

    @Test func failsWhenThereAreNoHoursLeft() {
        let sut = ForecastMapper()

        #expect(throws: ForecastError.unknown) {
            try sut.forecast(from: .fixture(currentTime: "2026-11-25T10:00"))
        }
    }
}
