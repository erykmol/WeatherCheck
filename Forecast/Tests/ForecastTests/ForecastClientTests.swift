//
//  ForecastClientTests.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking
import NetworkingTestHelpers
@testable import Forecast

struct ForecastClientTests {
    private func makeSUT(
        networkManager: FakeNetworkingManager = FakeNetworkingManager(result: .success(Data())),
        api: FakeForecastAPI = FakeForecastAPI(endpoint: Endpoint(method: .GET, path: "v1/forecast")),
        decoder: FakeResponseDecoder = FakeResponseDecoder(result: .success(ForecastResponse.fixture())),
        mapper: FakeForecastMapper = FakeForecastMapper(result: .success(.placeholder))
    ) -> ForecastClient {
        ForecastClient(networkManager: networkManager, api: api, decoder: decoder, mapper: mapper)
    }

    @Test(arguments: [true, false])
    func asksTheAPIForTheEndpointOfTheRequest(
        ignoringCache: Bool
    ) async throws {
        let api = FakeForecastAPI(endpoint: Endpoint(method: .GET, path: "v1/forecast"))
        let sut = makeSUT(api: api)

        _ = try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: ignoringCache)

        let expected = FakeForecastAPI.Request(latitude: 51.75, longitude: 19.46667, ignoringCache: ignoringCache)
        #expect(api.receivedRequests == [expected])
    }

    @Test func sendsTheEndpointFromTheAPI() async throws {
        let networkManager = FakeNetworkingManager(result: .success(Data()))
        let api = FakeForecastAPI(endpoint: Endpoint(method: .GET, path: "v1/endpoint-from-the-api"))
        let sut = makeSUT(networkManager: networkManager, api: api)

        _ = try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)

        #expect(networkManager.sentEndpoints.map(\.path) == ["v1/endpoint-from-the-api"])
    }

    @Test func decodesTheDataItReceives() async throws {
        let data = Data("forecast".utf8)
        let decoder = FakeResponseDecoder(result: .success(ForecastResponse.fixture()))
        let sut = makeSUT(networkManager: FakeNetworkingManager(result: .success(data)), decoder: decoder)

        _ = try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)

        #expect(decoder.receivedData == [data])
    }

    @Test func passesTheDecodedResponseToTheMapper() async throws {
        let mapper = FakeForecastMapper(result: .success(.placeholder))
        let decoder = FakeResponseDecoder(result: .success(ForecastResponse.fixture(currentTime: "2026-11-18T09:15")))
        let sut = makeSUT(decoder: decoder, mapper: mapper)

        _ = try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)

        #expect(mapper.receivedResponses.map(\.current.time) == ["2026-11-18T09:15"])
    }

    @Test func returnsTheMappedForecast() async throws {
        let sut = makeSUT(mapper: FakeForecastMapper(result: .success(.placeholder)))

        let forecast = try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)

        #expect(forecast == .placeholder)
    }

    @Test func passesTheMapperErrorOn() async {
        let sut = makeSUT(mapper: FakeForecastMapper(result: .failure(.unknown)))

        await #expect(throws: ForecastError.unknown) {
            try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)
        }
    }

    @Test func turnsARequestErrorIntoAForecastError() async {
        let sut = makeSUT(networkManager: FakeNetworkingManager(result: .failure(.offline)))

        await #expect(throws: ForecastError.offline) {
            try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)
        }
    }

    @Test func turnsADecodingErrorIntoAForecastError() async {
        let sut = makeSUT(decoder: FakeResponseDecoder(result: .failure(.unexpected("Couldn't decode the data"))))

        await #expect(throws: ForecastError.unknown) {
            try await sut.fetchForecast(latitude: 51.75, longitude: 19.46667, ignoringCache: false)
        }
    }
}
