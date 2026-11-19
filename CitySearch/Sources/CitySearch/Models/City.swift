//
//  City.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

public struct City: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let region: String?
    public let country: String?
    public let latitude: Double
    public let longitude: Double

    public init(
        id: Int,
        name: String,
        region: String?,
        country: String?,
        latitude: Double,
        longitude: Double
    ) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }

    public var subtitle: String {
        [region, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
