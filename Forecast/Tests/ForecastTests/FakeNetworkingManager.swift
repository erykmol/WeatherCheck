//
//  FakeNetworkingManager.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import os
import Networking

final class FakeNetworkingManager: NetworkingManagerProtocol {
    private let result: Result<Data, NetworkError>
    private let endpoints = OSAllocatedUnfairLock<[Endpoint]>(initialState: [])

    init(result: Result<Data, NetworkError>) {
        self.result = result
    }

    var sentEndpoints: [Endpoint] {
        endpoints.withLock { $0 }
    }

    func send(_ endpoint: Endpoint) async throws(NetworkError) -> Data {
        endpoints.withLock { $0.append(endpoint) }
        return try result.get()
    }
}
