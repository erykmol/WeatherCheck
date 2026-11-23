//
//  PreviewData.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

#if DEBUG
struct PreviewNetworkMonitor: NetworkMonitorProtocol {
    private let updates: [Connectivity]

    init(updates: [Connectivity] = []) {
        self.updates = updates
    }

    func monitorConnectivity() -> AsyncStream<Connectivity> {
        AsyncStream { continuation in
            updates.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}

struct PreviewForecastClient: ForecastClientProtocol {
    enum Response {
        case forecast(WeatherForecast)
        case failure(ForecastError)
        case pending
    }

    private let response: Response

    init(response: Response) {
        self.response = response
    }

    func forecast(latitude: Double, longitude: Double) async throws(ForecastError) -> WeatherForecast {
        switch response {
        case .forecast(let forecast):
            return forecast
        case .failure(let error):
            throw error
        case .pending:
            let (stream, continuation) = AsyncStream<Never>.makeStream()
            defer { continuation.finish() }
            for await _ in stream {}
            throw .unknown
        }
    }
}

extension ForecastViewModel {
    static func preview(
        _ response: PreviewForecastClient.Response,
        connectivity: [Connectivity] = []
    ) -> ForecastViewModel {
        ForecastViewModel(
            location: .preview,
            client: PreviewForecastClient(response: response),
            networkMonitor: PreviewNetworkMonitor(updates: connectivity)
        )
    }
}

extension ForecastLocation {
    static let preview = ForecastLocation(name: "Łódź", subtitle: "Łódzkie, Polska", latitude: 51.75, longitude: 19.46667)
}
#endif
