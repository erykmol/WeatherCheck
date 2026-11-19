//
//  FakeGeocodingClient.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
@testable import CitySearch

actor FakeGeocodingClient: GeocodingClientProtocol {
    private var results: [Result<[City], SearchError>]

    init(results: [Result<[City], SearchError>]) {
        self.results = results
    }

    func searchCities(named name: String) async throws(SearchError) -> [City] {
        let result = results.isEmpty ? .failure(.unknown) : results.removeFirst()
        return try result.get()
    }
}
