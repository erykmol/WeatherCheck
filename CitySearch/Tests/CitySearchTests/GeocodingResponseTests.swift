//
//  GeocodingResponseTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import Testing
@testable import CitySearch

struct GeocodingResponseTests {
    @Test func decodesThePlaces() throws {
        let json = #"{"results":[{"id":3093133,"name":"Łódź","latitude":51.75,"longitude":19.46667,"country":"Polska","admin1":"Łódzkie"}]}"#

        let sut = try JSONDecoder().decode(GeocodingResponse.self, from: Data(json.utf8))

        let place = try #require(sut.results?.first)
        #expect(place.id == 3093133)
        #expect(place.name == "Łódź")
        #expect(place.latitude == 51.75)
        #expect(place.longitude == 19.46667)
        #expect(place.country == "Polska")
        #expect(place.admin1 == "Łódzkie")
    }

    @Test func leavesAMissingCountryAndRegionEmpty() throws {
        let json = #"{"results":[{"id":1,"name":"Bez regionu","latitude":0,"longitude":0}]}"#

        let sut = try JSONDecoder().decode(GeocodingResponse.self, from: Data(json.utf8))

        let place = try #require(sut.results?.first)
        #expect(place.country == nil)
        #expect(place.admin1 == nil)
    }

    @Test func hasNoResultsWhenTheKeyIsMissing() throws {
        let sut = try JSONDecoder().decode(GeocodingResponse.self, from: Data(#"{"generationtime_ms":0.5}"#.utf8))

        #expect(sut.results == nil)
    }
}
