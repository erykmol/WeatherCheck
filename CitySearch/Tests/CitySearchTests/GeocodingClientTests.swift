//
//  GeocodingClientTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking
import NetworkingTestHelpers
@testable import CitySearch

struct GeocodingClientTests {
    private func makeSUT(session: StubURLSession) -> GeocodingClient {
        GeocodingClient(networkManager: NetworkingManager(
            builder: RequestBuilder(baseURL: GeocodingAPI.baseURL),
            session: session,
            errorMessage: OpenMeteoErrorDecoder().reason(from:)
        ))
    }

    @Test func mapsResultsToCities() async throws {
        let session = StubURLSession { request in
            let body = #"{"results":[{"id":3093133,"name":"Łódź","latitude":51.75,"longitude":19.46667,"country":"Polska","admin1":"Łódzkie"}]}"#
            return (.stub(200, for: request), Data(body.utf8))
        }
        let sut = makeSUT(session: session)

        let cities = try await sut.searchCities(named: "Łódź")

        #expect(cities == [.lodz])
    }

    @Test func treatsMissingResultsAsNoCities() async throws {
        let session = StubURLSession { request in
            (.stub(200, for: request), Data(#"{"generationtime_ms":0.5}"#.utf8))
        }
        let sut = makeSUT(session: session)

        let cities = try await sut.searchCities(named: "Kraqow")

        #expect(cities.isEmpty)
    }

    @Test func passesTheAPIReasonOn() async {
        let session = StubURLSession { request in
            (.stub(400, for: request), Data(#"{"error":true,"reason":"Parameter count must be between 1 and 100."}"#.utf8))
        }
        let sut = makeSUT(session: session)

        await #expect(throws: SearchError.server(message: "Parameter count must be between 1 and 100.")) {
            try await sut.searchCities(named: "Łódź")
        }
    }

    @Test func mapsNoConnectionToOffline() async {
        let session = StubURLSession { _ in throw URLError(.notConnectedToInternet) }
        let sut = makeSUT(session: session)

        await #expect(throws: SearchError.offline) {
            try await sut.searchCities(named: "Łódź")
        }
    }
}
