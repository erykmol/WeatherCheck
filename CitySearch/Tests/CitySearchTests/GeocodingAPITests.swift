//
//  GeocodingAPITests.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import Networking
@testable import CitySearch

struct GeocodingAPITests {
    @Test func searchesForTheGivenName() {
        let endpoint = GeocodingAPI.search(name: "Łódź")

        #expect(endpoint.query.contains(URLQueryItem(name: "name", value: "Łódź")))
    }

    @Test func asksForPolishNames() {
        let endpoint = GeocodingAPI.search(name: "Łódź")

        #expect(endpoint.query.contains(URLQueryItem(name: "language", value: "pl")))
    }
}
