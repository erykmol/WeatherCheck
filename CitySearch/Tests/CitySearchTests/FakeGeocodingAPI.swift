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
    private let endpoint: Endpoint
    private let names = OSAllocatedUnfairLock<[String]>(initialState: [])

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    var receivedNames: [String] {
        names.withLock { $0 }
    }

    func makeSearchEndpoint(name: String) -> Endpoint {
        names.withLock { $0.append(name) }
        return endpoint
    }
}
