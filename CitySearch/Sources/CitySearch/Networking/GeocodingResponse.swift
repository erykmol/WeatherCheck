//
//  GeocodingResponse.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct GeocodingResponse: Decodable, Sendable {
    let results: [Place]?

    struct Place: Decodable, Sendable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        let country: String?
        let admin1: String?
    }
}

extension City {
    init(_ place: GeocodingResponse.Place) {
        self.init(
            id: place.id,
            name: place.name,
            region: place.admin1,
            country: place.country,
            latitude: place.latitude,
            longitude: place.longitude
        )
    }
}
