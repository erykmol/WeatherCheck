//
//  ForecastViewModel.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Observation
import Networking

@MainActor
@Observable
final class ForecastViewModel {
    enum State: Equatable {
        case loading
        case loaded(WeatherForecast, updatedAt: Date)
        case offline
        case failed(message: String?)
    }
    
    var navigationTitle: String {
        switch state {
        case .loading, .loaded:
            location.name
        case .offline, .failed:
            ""
        }
    }

    let location: ForecastLocation
    private(set) var state: State = .loading

    private let client: any ForecastClientProtocol
    private let networkMonitor: any NetworkMonitorProtocol
    private let now: () -> Date

    init(
        location: ForecastLocation,
        client: any ForecastClientProtocol = ForecastClient(decoder: ResponseDecoder(), mapper: ForecastMapper()),
        networkMonitor: any NetworkMonitorProtocol = NetworkMonitor(),
        now: @escaping () -> Date = { Date() }
    ) {
        self.location = location
        self.client = client
        self.networkMonitor = networkMonitor
        self.now = now
    }

    

    func load() async {
        guard case .loading = state else { return }
        await fetch()
    }

    func refresh() async {
        await fetch(keepingForecastOnFailure: true)
    }

    func observeConnectivity() async {
        for await connectivity in networkMonitor.connectivityUpdates() where connectivity == .connected {
            guard case .offline = state else { continue }
            await retry()
        }
    }

    func retry() async {
        state = .loading
        await fetch()
    }

    private func fetch(keepingForecastOnFailure: Bool = false) async {
        do throws(ForecastError) {
            let forecast = try await client.forecast(latitude: location.latitude, longitude: location.longitude)
            state = .loaded(forecast, updatedAt: now())
        } catch {
            guard !Task.isCancelled else { return }
            if keepingForecastOnFailure, case .loaded = state {
                logger.error("Refresh failed, keeping the last forecast: \(String(describing: error), privacy: .public)")
                return
            }
            switch error {
            case .offline:
                state = .offline
            case .server(let message):
                state = .failed(message: message)
            case .unknown:
                state = .failed(message: nil)
            }
        }
    }
}
