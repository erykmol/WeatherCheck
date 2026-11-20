//
//  FakeForecastAPI.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import os
import Networking
@testable import Forecast

final class FakeForecastAPI: ForecastAPIProtocol {
    struct Request: Equatable, Sendable {
        let latitude: Double
        let longitude: Double
    }

    private let endpoint: Endpoint
    private let requests = OSAllocatedUnfairLock<[Request]>(initialState: [])

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    var receivedRequests: [Request] {
        requests.withLock { $0 }
    }

    func forecast(latitude: Double, longitude: Double) -> Endpoint {
        requests.withLock { $0.append(Request(latitude: latitude, longitude: longitude)) }
        return endpoint
    }
}
