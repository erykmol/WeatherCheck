//
//  FakeGeocodingAPI.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import os
import Networking
@testable import CitySearch

final class FakeGeocodingAPI: GeocodingAPIProtocol {
    struct Request: Equatable, Sendable {
        let name: String
        let ignoringCache: Bool
    }

    private let endpoint: Endpoint
    private let requests = OSAllocatedUnfairLock<[Request]>(initialState: [])

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    var receivedRequests: [Request] {
        requests.withLock { $0 }
    }

    func makeSearchEndpoint(name: String, ignoringCache: Bool) -> Endpoint {
        requests.withLock { $0.append(Request(name: name, ignoringCache: ignoringCache)) }
        return endpoint
    }
}
