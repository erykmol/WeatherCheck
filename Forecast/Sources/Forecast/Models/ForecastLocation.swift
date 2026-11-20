//
//  ForecastLocation.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

public struct ForecastLocation: Hashable, Sendable {
    public let name: String
    public let subtitle: String
    public let latitude: Double
    public let longitude: Double

    public init(name: String, subtitle: String, latitude: Double, longitude: Double) {
        self.name = name
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }
}
