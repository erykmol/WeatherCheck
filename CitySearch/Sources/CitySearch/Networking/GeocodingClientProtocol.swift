//
//  GeocodingClientProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

protocol GeocodingClientProtocol: Sendable {
    func searchCities(named name: String) async throws(SearchError) -> [City]
}
