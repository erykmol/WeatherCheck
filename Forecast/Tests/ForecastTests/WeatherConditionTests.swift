//
//  WeatherConditionTests.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
@testable import Forecast

private let codes: [(Int, WeatherCondition)] = [
    (0, .clear),
    (1, .mainlyClear),
    (2, .partlyCloudy),
    (3, .overcast),
    (45, .fog),
    (48, .fog),
    (53, .drizzle),
    (61, .rain),
    (80, .rain),
    (65, .heavyRain),
    (82, .heavyRain),
    (73, .snow),
    (86, .snow),
    (95, .thunderstorm),
    (99, .thunderstorm),
    (4, .unknown),
]

struct WeatherConditionTests {
    @Test(arguments: codes)
    func mapsWMOCodes(code: Int, condition: WeatherCondition) {
        let sut = WeatherCondition(code: code)

        #expect(sut == condition)
    }

    @Test func usesNightSymbolsAfterDark() {
        let sut = WeatherCondition.clear

        #expect(sut.symbolName(isDay: true) == "sun.max.fill")
        #expect(sut.symbolName(isDay: false) == "moon.stars.fill")
    }

    @Test func fallsBackToACloudForUnknownCodes() {
        let sut = WeatherCondition.unknown

        #expect(sut.symbolName(isDay: true) == "cloud.fill")
    }
}
