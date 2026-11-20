//
//  ForecastResponse.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct ForecastResponse: Decodable, Sendable {
    let current: Current
    let hourly: Hourly
    let daily: Daily

    struct Current: Decodable, Sendable {
        let time: String
        let temperature: Double
        let cloudCover: Double
        let weatherCode: Int
        let isDay: Int

        enum CodingKeys: String, CodingKey {
            case time
            case temperature = "temperature_2m"
            case cloudCover = "cloud_cover"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }
    }

    struct Hourly: Decodable, Sendable {
        let time: [String]
        let temperature: [Double?]
        let precipitationProbability: [Double?]
        let weatherCode: [Int?]
        let isDay: [Int?]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature = "temperature_2m"
            case precipitationProbability = "precipitation_probability"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }
    }

    struct Daily: Decodable, Sendable {
        let time: [String]
        let weatherCode: [Int?]
        let temperatureMax: [Double?]
        let temperatureMin: [Double?]
        let precipitationProbabilityMax: [Double?]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case precipitationProbabilityMax = "precipitation_probability_max"
        }
    }
}
