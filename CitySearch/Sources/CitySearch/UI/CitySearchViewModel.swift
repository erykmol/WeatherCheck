//
//  CitySearchViewModel.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Observation
import Networking

@MainActor
@Observable
final class CitySearchViewModel {
    enum Content: Equatable {
        case idle
        case searching
        case results([City])
        case noResults(query: String)
        case invalidName
        case nameTooLong
        case failed(message: String?)
    }

    struct SearchRequest: Equatable {
        let query: String
        let attempt: Int
    }

    var query = ""
    private(set) var content: Content = .idle
    private(set) var history: [City] = []
    private var hasConnection = true
    private var lastSearchFailedOffline = false
    private var attempt = 0

    var isOffline: Bool {
        !hasConnection || lastSearchFailedOffline
    }

    var request: SearchRequest {
        SearchRequest(query: query, attempt: attempt)
    }

    private let geocoding: any GeocodingClientProtocol
    private let validator: any CityNameValidatorProtocol
    private let networkMonitor: any NetworkMonitorProtocol
    private let historyStore: any SearchHistoryStoring
    private let debounce: Duration
    private let onCitySelected: (City) -> Void

    init(
        geocoding: any GeocodingClientProtocol = GeocodingClient(),
        validator: any CityNameValidatorProtocol,
        networkMonitor: any NetworkMonitorProtocol,
        history: any SearchHistoryStoring,
        debounce: Duration = Constants.debounce,
        onCitySelected: @escaping (City) -> Void
    ) {
        self.geocoding = geocoding
        self.validator = validator
        self.networkMonitor = networkMonitor
        self.historyStore = history
        self.debounce = debounce
        self.onCitySelected = onCitySelected
    }

    func loadHistory() {
        do {
            history = try historyStore.load()
        } catch {
            logger.error("Couldn't load search history: \(String(describing: error), privacy: .public)")
        }
    }

    func search() async {
        switch validator.validate(query) {
        case .empty, .tooShort:
            content = .idle
        case .invalid:
            content = .invalidName
        case .tooLong:
            content = .nameTooLong
        case .valid(let name):
            do {
                try await Task.sleep(for: debounce)
            } catch {
                return
            }
            content = .searching
            await searchCities(named: name)
        }
    }

    func observeConnectivity() async {
        for await connectivity in networkMonitor.connectivityUpdates() {
            switch connectivity {
            case .disconnected:
                hasConnection = false
            case .connected:
                guard isOffline else { continue }
                hasConnection = true
                lastSearchFailedOffline = false
                retry()
            }
        }
    }

    func retry() {
        attempt += 1
    }

    func select(_ city: City) {
        updateHistory { try historyStore.record(city) }
        onCitySelected(city)
    }

    func remove(_ city: City) {
        updateHistory { try historyStore.remove(city) }
    }

    func clearHistory() {
        updateHistory { try historyStore.removeAll() }
    }

    private func searchCities(named name: String) async {
        do throws(SearchError) {
            let cities = try await geocoding.searchCities(named: name)
            guard !Task.isCancelled else { return }
            lastSearchFailedOffline = false
            content = cities.isEmpty ? .noResults(query: name) : .results(cities)
        } catch {
            guard !Task.isCancelled else { return }
            switch error {
            case .offline:
                lastSearchFailedOffline = true
                content = .idle
            case .server(let message):
                content = .failed(message: message)
            case .unknown:
                content = .failed(message: nil)
            }
        }
    }

    private func updateHistory(_ change: () throws -> Void) {
        do {
            try change()
            history = try historyStore.load()
        } catch {
            logger.error("Couldn't update search history: \(String(describing: error), privacy: .public)")
        }
    }
}

private enum Constants {
    static let debounce: Duration = .milliseconds(300)
}
