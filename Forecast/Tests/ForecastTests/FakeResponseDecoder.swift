//
//  FakeResponseDecoder.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import os
import Networking
@testable import Forecast

final class FakeResponseDecoder: ResponseDecoderProtocol {
    private let result: Result<ForecastResponse, NetworkError>
    private let payloads = OSAllocatedUnfairLock<[Data]>(initialState: [])

    init(result: Result<ForecastResponse, NetworkError>) {
        self.result = result
    }

    var receivedData: [Data] {
        payloads.withLock { $0 }
    }

    func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws(NetworkError) -> T {
        payloads.withLock { $0.append(data) }
        guard let value = try result.get() as? T else {
            throw .unexpected("FakeResponseDecoder only returns a ForecastResponse")
        }
        return value
    }
}
