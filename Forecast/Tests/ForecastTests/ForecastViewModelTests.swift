//
//  ForecastViewModelTests.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking
import NetworkingTestHelpers
@testable import Forecast

@MainActor
struct ForecastViewModelTests {
    private let updatedAt = Date(timeIntervalSince1970: 1_795_000_000.0)

    private func makeSUT(
        _ results: Result<WeatherForecast, ForecastError>...,
        connectivity: [Connectivity] = []
    ) -> ForecastViewModel {
        ForecastViewModel(
            location: .lodz,
            client: FakeForecastClient(results: results),
            networkMonitor: StubNetworkMonitor(updates: connectivity),
            now: { [updatedAt] in updatedAt }
        )
    }

    @Test func startsLoading() {
        let sut = makeSUT()

        #expect(sut.state == .loading)
        #expect(sut.navigationTitle == "Łódź")
    }

    @Test func loadShowsTheForecast() async {
        let sut = makeSUT(.success(.placeholder))

        await sut.load()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func loadShowsOfflineWhenThereIsNoConnection() async {
        let sut = makeSUT(.failure(.offline))

        await sut.load()

        #expect(sut.state == .offline)
        #expect((sut.navigationTitle == ""))
    }

    @Test func loadPassesTheAPIReasonOn() async {
        let sut = makeSUT(.failure(.server(message: "Latitude must be in range")))

        await sut.load()

        #expect(sut.state == .failed(message: "Latitude must be in range"))
    }

    @Test func loadShowsAFailureWithoutAReasonForUnknownErrors() async {
        let sut = makeSUT(.failure(.unknown))

        await sut.load()

        #expect(sut.state == .failed(message: nil))
    }

    @Test func loadDoesNothingOnceThereIsAForecast() async {
        let sut = makeSUT(.success(.placeholder), .failure(.offline))

        await sut.load()
        await sut.load()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func retryLoadsAgain() async {
        let sut = makeSUT(.failure(.offline), .success(.placeholder))

        await sut.load()
        await sut.retry()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func refreshKeepsTheForecastWhenItFails() async {
        let sut = makeSUT(.success(.placeholder), .failure(.offline))

        await sut.load()
        await sut.refresh()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func retriesWhenTheConnectionComesBackWhileOffline() async {
        let sut = makeSUT(.failure(.offline), .success(.placeholder), connectivity: [.connected])
        await sut.load()

        await sut.observeConnectivity()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func keepsTheForecastWhenTheConnectionComesBack() async {
        let sut = makeSUT(.success(.placeholder), .success(.refreshed), connectivity: [.connected])
        await sut.load()

        await sut.observeConnectivity()

        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func showsTheOfflineBannerOverTheForecastWhenTheConnectionDrops() async {
        let sut = makeSUT(.success(.placeholder), connectivity: [.disconnected])
        await sut.load()

        await sut.observeConnectivity()

        #expect(sut.isOffline)
        #expect(sut.state == .loaded(.placeholder, updatedAt: updatedAt))
    }

    @Test func showsTheOfflineBannerWhenARefreshFailsWithoutAConnection() async {
        let sut = makeSUT(.success(.placeholder), .failure(.offline))
        await sut.load()

        await sut.refresh()

        #expect(sut.isOffline)
    }

    @Test func doesNotShowTheOfflineBannerWhenARefreshFailsForAnotherReason() async {
        let sut = makeSUT(.success(.placeholder), .failure(.server(message: "Latitude must be in range")))
        await sut.load()

        await sut.refresh()

        #expect(!sut.isOffline)
    }

    @Test func refreshesAndHidesTheBannerWhenTheConnectionComesBack() async {
        let sut = makeSUT(.success(.placeholder), .failure(.offline), .success(.refreshed), connectivity: [.connected])
        await sut.load()
        await sut.refresh()

        await sut.observeConnectivity()

        #expect(!sut.isOffline)
        #expect(sut.state == .loaded(.refreshed, updatedAt: updatedAt))
    }
}
