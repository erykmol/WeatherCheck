//
//  WeatherCondition+Presentation.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI

extension WeatherCondition {
    var title: Text {
        switch self {
        case .clear: Localizable.conditionClear
        case .mainlyClear: Localizable.conditionMainlyClear
        case .partlyCloudy: Localizable.conditionPartlyCloudy
        case .overcast: Localizable.conditionOvercast
        case .fog: Localizable.conditionFog
        case .drizzle: Localizable.conditionDrizzle
        case .rain: Localizable.conditionRain
        case .heavyRain: Localizable.conditionHeavyRain
        case .snow: Localizable.conditionSnow
        case .thunderstorm: Localizable.conditionThunderstorm
        case .unknown: Localizable.conditionUnknown
        }
    }

    func symbolName(isDay: Bool) -> String {
        switch self {
        case .clear: isDay ? "sun.max.fill" : "moon.stars.fill"
        case .mainlyClear, .partlyCloudy: isDay ? "cloud.sun.fill" : "cloud.moon.fill"
        case .overcast, .unknown: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .rain: "cloud.rain.fill"
        case .heavyRain: "cloud.heavyrain.fill"
        case .snow: "cloud.snow.fill"
        case .thunderstorm: "cloud.bolt.rain.fill"
        }
    }
}

enum CloudCoverDescription {
    static func title(for percent: Int) -> Text {
        switch percent {
        case ..<Constants.fewClouds: Localizable.cloudCoverLow
        case ..<Constants.someClouds: Localizable.cloudCoverModerate
        case ..<Constants.manyClouds: Localizable.cloudCoverHigh
        default: Localizable.cloudCoverFull
        }
    }
}

enum TemperatureFormat {
    static func string(_ celsius: Double) -> String {
        "\(Int(celsius.rounded()))°"
    }
}

private enum Constants {
    static let fewClouds = 20
    static let someClouds = 50
    static let manyClouds = 90
}
