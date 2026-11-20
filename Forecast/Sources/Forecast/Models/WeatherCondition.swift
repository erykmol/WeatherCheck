//
//  WeatherCondition.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

enum WeatherCondition: Equatable, Sendable {
    case clear
    case mainlyClear
    case partlyCloudy
    case overcast
    case fog
    case drizzle
    case rain
    case heavyRain
    case snow
    case thunderstorm
    case unknown

    init(code: Int) {
        switch code {
        case 0: self = .clear
        case 1: self = .mainlyClear
        case 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51...57: self = .drizzle
        case 61, 63, 66, 80, 81: self = .rain
        case 65, 67, 82: self = .heavyRain
        case 71...77, 85, 86: self = .snow
        case 95...99: self = .thunderstorm
        default: self = .unknown
        }
    }
}
