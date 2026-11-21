//
//  FakeNetworkingManager.swift
//  Networking
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import os
import Networking

public final class FakeNetworkingManager: NetworkingManagerProtocol {
    private let result: Result<Data, NetworkError>
    private let endpoints = OSAllocatedUnfairLock<[Endpoint]>(initialState: [])

    public init(result: Result<Data, NetworkError>) {
        self.result = result
    }

    public var sentEndpoints: [Endpoint] {
        endpoints.withLock { $0 }
    }

    public func send(_ endpoint: Endpoint) async throws(NetworkError) -> Data {
        endpoints.withLock { $0.append(endpoint) }
        return try result.get()
    }
}
