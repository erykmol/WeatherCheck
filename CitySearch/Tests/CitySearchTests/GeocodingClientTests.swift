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
    private func makeSUT(
        networkManager: FakeNetworkingManager = FakeNetworkingManager(result: .success(Data())),
        api: FakeGeocodingAPI = FakeGeocodingAPI(endpoint: Endpoint(method: .GET, path: "v1/search")),
        decoder: FakeResponseDecoder = FakeResponseDecoder(result: .success(GeocodingResponse(results: [])))
    ) -> GeocodingClient {
        GeocodingClient(networkManager: networkManager, api: api, decoder: decoder)
    }

    @Test func asksTheAPIForTheEndpointOfTheName() async throws {
        let api = FakeGeocodingAPI(endpoint: Endpoint(method: .GET, path: "v1/search"))
        let sut = makeSUT(api: api)

        _ = try await sut.searchCities(named: "Łódź")

        #expect(api.receivedNames == ["Łódź"])
    }

    @Test func sendsTheEndpointFromTheAPI() async throws {
        let networkManager = FakeNetworkingManager(result: .success(Data()))
        let api = FakeGeocodingAPI(endpoint: Endpoint(method: .GET, path: "v1/endpoint-from-the-api"))
        let sut = makeSUT(networkManager: networkManager, api: api)

        _ = try await sut.searchCities(named: "Łódź")

        #expect(networkManager.sentEndpoints.map(\.path) == ["v1/endpoint-from-the-api"])
    }

    @Test func decodesTheDataItReceives() async throws {
        let data = Data("cities".utf8)
        let decoder = FakeResponseDecoder(result: .success(GeocodingResponse(results: [])))
        let sut = makeSUT(networkManager: FakeNetworkingManager(result: .success(data)), decoder: decoder)

        _ = try await sut.searchCities(named: "Łódź")

        #expect(decoder.receivedData == [data])
    }

    @Test func returnsTheCitiesOfTheResults() async throws {
        let place = GeocodingResponse.Place(
            id: 3093133,
            name: "Łódź",
            latitude: 51.75,
            longitude: 19.46667,
            country: "Polska",
            admin1: "Łódzkie"
        )
        let sut = makeSUT(decoder: FakeResponseDecoder(result: .success(GeocodingResponse(results: [place]))))

        let cities = try await sut.searchCities(named: "Łódź")

        #expect(cities == [.lodz])
    }

    @Test func treatsMissingResultsAsNoCities() async throws {
        let sut = makeSUT(decoder: FakeResponseDecoder(result: .success(GeocodingResponse(results: nil))))

        let cities = try await sut.searchCities(named: "Kraqow")

        #expect(cities.isEmpty)
    }

    @Test func turnsARequestErrorIntoASearchError() async {
        let sut = makeSUT(networkManager: FakeNetworkingManager(result: .failure(.offline)))

        await #expect(throws: SearchError.offline) {
            try await sut.searchCities(named: "Łódź")
        }
    }

    @Test func turnsADecodingErrorIntoASearchError() async {
        let sut = makeSUT(decoder: FakeResponseDecoder(result: .failure(.unexpected("Couldn't decode the data"))))

        await #expect(throws: SearchError.unknown) {
            try await sut.searchCities(named: "Łódź")
        }
    }
}
