//
//  ForecastMapper.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct ForecastMapper: ForecastMapperProtocol {
    func mapForecast(from response: ForecastResponse) throws(ForecastError) -> WeatherForecast {
        let hourly = response.hourly
        let daily = response.daily
        let currentHour = response.current.time.prefix(Constants.hourKeyLength)

        guard let start = hourly.time.firstIndex(where: { $0.prefix(Constants.hourKeyLength) >= currentHour }) else {
            logger.error("No hourly data at or after \(response.current.time, privacy: .public)")
            throw .unknown
        }
        let end = min(start + Constants.hourCount, hourly.time.count)

        let hours = (start..<end).compactMap { index -> WeatherForecast.Hour? in
            guard let temperature = readValue(in: hourly.temperature, at: index) else { return nil }
            let time = hourly.time[index]
            return WeatherForecast.Hour(
                id: time,
                isNow: index == start,
                hour: String(time.dropFirst(Constants.hourOffset).prefix(Constants.hourLength)),
                temperature: temperature,
                rainChance: readValue(in: hourly.precipitationProbability, at: index).map(roundToPercent),
                condition: WeatherCondition(code: readValue(in: hourly.weatherCode, at: index) ?? Constants.unknownCode),
                isDay: readValue(in: hourly.isDay, at: index) == 1
            )
        }

        let days = daily.time.indices.compactMap { index -> WeatherForecast.Day? in
            guard
                let low = readValue(in: daily.temperatureMin, at: index),
                let high = readValue(in: daily.temperatureMax, at: index)
            else { return nil }
            let date = daily.time[index]
            return WeatherForecast.Day(
                id: date,
                isToday: index == daily.time.startIndex,
                weekday: formatWeekday(for: date),
                minTemperature: min(low, high),
                maxTemperature: max(low, high),
                rainChance: readValue(in: daily.precipitationProbabilityMax, at: index).map(roundToPercent),
                condition: WeatherCondition(code: readValue(in: daily.weatherCode, at: index) ?? Constants.unknownCode)
            )
        }

        let current = WeatherForecast.Current(
            temperature: response.current.temperature,
            cloudCover: roundToPercent(response.current.cloudCover),
            rainChance: readValue(in: hourly.precipitationProbability, at: start).map(roundToPercent),
            condition: WeatherCondition(code: response.current.weatherCode),
            isDay: response.current.isDay == 1
        )

        return WeatherForecast(current: current, hours: hours, days: days)
    }

    private func readValue<T>(in array: [T?], at index: Int) -> T? {
        array.indices.contains(index) ? array[index] : nil
    }

    private func roundToPercent(_ value: Double) -> Int {
        Int(value.rounded())
    }

    private func formatWeekday(for isoDate: String) -> String {
        guard let date = try? Date(isoDate, strategy: Date.ISO8601FormatStyle().year().month().day()) else {
            return isoDate
        }
        return date.formatted(Self.weekdayStyle)
    }

    private static let weekdayStyle = Date.FormatStyle(
        locale: Locale(identifier: "pl_PL"),
        calendar: Calendar(identifier: .gregorian),
        timeZone: .gmt,
        capitalizationContext: .beginningOfSentence
    ).weekday(.abbreviated)
}

private enum Constants {
    static let hourCount = 24
    static let hourKeyLength = 13
    static let hourOffset = 11
    static let hourLength = 2
    static let unknownCode = -1
}
