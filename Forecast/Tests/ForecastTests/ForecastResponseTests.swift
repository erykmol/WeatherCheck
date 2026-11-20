//
//  ForecastResponseTests.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
@testable import Forecast

struct ForecastResponseTests {
    private static let sampleJSON = """
    {
      "latitude": 51.75, "longitude": 19.47, "timezone": "Europe/Warsaw", "utc_offset_seconds": 3600,
      "current": { "time": "2026-11-18T14:30", "interval": 900, "temperature_2m": 6.1, "cloud_cover": 85, "weather_code": 3, "is_day": 1 },
      "hourly": {
        "time": ["2026-11-18T14:00", "2026-11-18T15:00"],
        "temperature_2m": [6.1, null],
        "precipitation_probability": [35, null],
        "weather_code": [3, null],
        "is_day": [1, null]
      },
      "daily": {
        "time": ["2026-11-18"],
        "weather_code": [61],
        "temperature_2m_max": [8.2],
        "temperature_2m_min": [3.1],
        "precipitation_probability_max": [60]
      }
    }
    """

    @Test func decodesTheCurrentConditions() throws {
        let sut = try JSONDecoder().decode(ForecastResponse.self, from: Data(Self.sampleJSON.utf8))

        #expect(sut.current.time == "2026-11-18T14:30")
        #expect(sut.current.temperature == 6.1)
        #expect(sut.current.cloudCover == 85)
        #expect(sut.current.weatherCode == 3)
        #expect(sut.current.isDay == 1)
    }

    @Test func decodesTheHoursWithMissingValues() throws {
        let sut = try JSONDecoder().decode(ForecastResponse.self, from: Data(Self.sampleJSON.utf8))

        #expect(sut.hourly.time == ["2026-11-18T14:00", "2026-11-18T15:00"])
        #expect(sut.hourly.temperature == [6.1, nil])
        #expect(sut.hourly.precipitationProbability == [35, nil])
        #expect(sut.hourly.weatherCode == [3, nil])
        #expect(sut.hourly.isDay == [1, nil])
    }

    @Test func decodesTheDays() throws {
        let sut = try JSONDecoder().decode(ForecastResponse.self, from: Data(Self.sampleJSON.utf8))

        #expect(sut.daily.time == ["2026-11-18"])
        #expect(sut.daily.weatherCode == [61])
        #expect(sut.daily.temperatureMax == [8.2])
        #expect(sut.daily.temperatureMin == [3.1])
        #expect(sut.daily.precipitationProbabilityMax == [60])
    }
}
