//
//  CitySearchViewModelTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking
import NetworkingTestHelpers
@testable import CitySearch

@MainActor
struct CitySearchViewModelTests {
    private func makeSUT(
        _ results: Result<[City], SearchError>...,
        validation: CityNameValidation = .valid("Łódź"),
        connectivity: [Connectivity] = [],
        store: FakeHistoryStore = FakeHistoryStore(),
        onCitySelected: @escaping (City) -> Void = { _ in }
    ) -> CitySearchViewModel {
        makeSUT(
            geocoding: FakeGeocodingClient(results: results),
            validation: validation,
            connectivity: connectivity,
            store: store,
            onCitySelected: onCitySelected
        )
    }

    private func makeSUT(
        geocoding: FakeGeocodingClient,
        validation: CityNameValidation = .valid("Łódź"),
        connectivity: [Connectivity] = [],
        store: FakeHistoryStore = FakeHistoryStore(),
        onCitySelected: @escaping (City) -> Void = { _ in }
    ) -> CitySearchViewModel {
        CitySearchViewModel(
            geocoding: geocoding,
            validator: FakeCityNameValidator(validation: validation),
            networkMonitor: StubNetworkMonitor(updates: connectivity),
            history: store,
            debounce: .zero,
            onCitySelected: onCitySelected
        )
    }

    @Test func showsResultsForAValidName() async {
        let sut = makeSUT(.success([.lodz]))

        await sut.searchIfNeeded()

        #expect(sut.content == .results([.lodz], query: "Łódź"))
    }

    @Test func showsNoResultsForTheValidatedName() async {
        let sut = makeSUT(.success([]), validation: .valid("Kraqow"))
        sut.query = " Kraqow "

        await sut.searchIfNeeded()

        #expect(sut.content == .noResults(query: "Kraqow"))
    }

    @Test func flagsAnInvalidNameWithoutSearching() async {
        let sut = makeSUT(.success([.lodz]), validation: .invalid)

        await sut.searchIfNeeded()

        #expect(sut.content == .invalidName)
    }

    @Test func flagsANameThatIsTooLongWithoutSearching() async {
        let sut = makeSUT(.success([.lodz]), validation: .tooLong)

        await sut.searchIfNeeded()

        #expect(sut.content == .nameTooLong)
    }

    @Test(arguments: [CityNameValidation.empty, .tooShort])
    func goesBackToHistoryWithoutASearchableName(
        validation: CityNameValidation
    ) async {
        let sut = makeSUT(.success([.lodz]), validation: validation)

        await sut.searchIfNeeded()

        #expect(sut.content == .idle)
    }

    @Test func showsHistoryWithTheOfflineFlagWhenThereIsNoConnection() async {
        let sut = makeSUT(.failure(.offline))

        await sut.searchIfNeeded()

        #expect(sut.content == .idle)
        #expect(sut.isOffline)
    }

    @Test func clearsTheOfflineFlagAfterASuccessfulSearch() async {
        let sut = makeSUT(.failure(.offline), .success([.lodz]))
        await sut.searchIfNeeded()
        #expect(sut.isOffline)

        await sut.searchIfNeeded()

        #expect(!sut.isOffline)
        #expect(sut.content == .results([.lodz], query: "Łódź"))
    }

    @Test func showsTheOfflineBannerWhenTheConnectionDrops() async {
        let sut = makeSUT(connectivity: [.disconnected])

        await sut.observeConnectivity()

        #expect(sut.isOffline)
    }

    @Test func keepsTheBannerWhileDisconnectedWhenASearchSucceeds() async {
        let sut = makeSUT(.success([.lodz]), connectivity: [.disconnected])
        await sut.observeConnectivity()

        await sut.searchIfNeeded()

        #expect(sut.content == .results([.lodz], query: "Łódź"))
        #expect(sut.isOffline)
    }

    @Test func searchesAgainWhenTheConnectionComesBack() async {
        let sut = makeSUT(.failure(.offline), connectivity: [.connected])
        await sut.searchIfNeeded()
        let before = sut.request

        await sut.observeConnectivity()

        #expect(!sut.isOffline)
        #expect(sut.request != before)
    }

    @Test func doesNotSearchAgainWhenTheConnectionWasNotLost() async {
        let sut = makeSUT(connectivity: [.connected])
        let before = sut.request

        await sut.observeConnectivity()

        #expect(sut.request == before)
    }

    @Test func passesTheAPIReasonOn() async {
        let sut = makeSUT(.failure(.server(message: "Parameter count must be between 1 and 100.")))

        await sut.searchIfNeeded()

        #expect(sut.content == .failed(message: "Parameter count must be between 1 and 100."))
    }

    @Test func retryStartsANewRequestForTheSameQuery() {
        let sut = makeSUT()
        sut.query = "Łódź"
        let before = sut.request

        sut.retry()

        #expect(sut.request != before)
        #expect(sut.request.query == before.query)
    }

    @Test func retryIgnoresTheCacheForTheNextSearchOnly() async {
        let geocoding = FakeGeocodingClient(results: [])
        let sut = makeSUT(geocoding: geocoding)
        await sut.searchIfNeeded()

        sut.retry()
        await sut.searchIfNeeded()
        await sut.searchIfNeeded()

        let requests = await geocoding.receivedRequests
        #expect(requests.map(\.ignoringCache) == [false, true, false])
    }

    @Test func loadsHistoryFromTheStore() {
        let sut = makeSUT(store: FakeHistoryStore(cities: [.krakow]))

        sut.loadHistory()

        #expect(sut.history == [.krakow])
    }

    @Test func selectingACityRecordsItAndReportsIt() {
        var selected: City?
        let sut = makeSUT(store: FakeHistoryStore(cities: [.krakow]), onCitySelected: { selected = $0 })
        sut.loadHistory()

        sut.select(.lodz)

        #expect(sut.history == [.lodz, .krakow])
        #expect(selected == .lodz)
    }

    @Test func removingACityUpdatesTheHistory() {
        let sut = makeSUT(store: FakeHistoryStore(cities: [.lodz, .krakow]))
        sut.loadHistory()

        sut.remove(.lodz)

        #expect(sut.history == [.krakow])
    }

    @Test func clearingEmptiesTheHistory() {
        let sut = makeSUT(store: FakeHistoryStore(cities: [.lodz, .krakow]))
        sut.loadHistory()

        sut.clearHistory()

        #expect(sut.history.isEmpty)
    }
    
    @Test func keepsTheResultsWhenTheValidatedNameHasNotChanged() async {
        let sut = makeSUT(.success([.lodz]))
        sut.query = "Łódź"
        await sut.searchIfNeeded()

        sut.query = "Łódź "
        await sut.searchIfNeeded()

        #expect(sut.content == .results([.lodz], query: "Łódź"))
    }
}
