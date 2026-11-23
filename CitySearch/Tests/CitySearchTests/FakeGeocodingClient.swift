//
//  FakeGeocodingClient.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
@testable import CitySearch

actor FakeGeocodingClient: GeocodingClientProtocol {
    struct Request: Equatable, Sendable {
        let name: String
        let ignoringCache: Bool
    }

    private var results: [Result<[City], SearchError>]
    private(set) var receivedRequests: [Request] = []

    init(results: [Result<[City], SearchError>]) {
        self.results = results
    }

    func searchCities(
        named name: String,
        ignoringCache: Bool
    ) async throws(SearchError) -> [City] {
        receivedRequests.append(Request(name: name, ignoringCache: ignoringCache))
        let result = results.isEmpty ? .failure(.unknown) : results.removeFirst()
        return try result.get()
    }
}
