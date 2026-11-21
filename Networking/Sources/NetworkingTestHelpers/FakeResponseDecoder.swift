//
//  FakeResponseDecoder.swift
//  Networking
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import os
import Networking

public final class FakeResponseDecoder: ResponseDecoderProtocol {
    private let result: Result<any Sendable, NetworkError>
    private let payloads = OSAllocatedUnfairLock<[Data]>(initialState: [])

    public init(result: Result<any Sendable, NetworkError>) {
        self.result = result
    }

    public var receivedData: [Data] {
        payloads.withLock { $0 }
    }

    public func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws(NetworkError) -> T {
        payloads.withLock { $0.append(data) }
        guard let value = try result.get() as? T else {
            throw .unexpected("FakeResponseDecoder has no \(T.self) to return")
        }
        return value
    }
}
