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
        let sut = GeocodingAPI()

        let endpoint = sut.makeSearchEndpoint(name: "Łódź", ignoringCache: false)

        #expect(endpoint.query.contains(URLQueryItem(name: "name", value: "Łódź")))
    }

    @Test func asksForPolishNames() {
        let sut = GeocodingAPI()

        let endpoint = sut.makeSearchEndpoint(name: "Łódź", ignoringCache: false)

        #expect(endpoint.query.contains(URLQueryItem(name: "language", value: "pl")))
    }

    @Test(arguments: [true, false])
    func ignoresTheCacheOnlyWhenAsked(ignoringCache: Bool) {
        let sut = GeocodingAPI()

        let endpoint = sut.makeSearchEndpoint(name: "Łódź", ignoringCache: ignoringCache)

        #expect(endpoint.ignoresCache == ignoringCache)
    }
}
