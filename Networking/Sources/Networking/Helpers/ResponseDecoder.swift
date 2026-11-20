//
//  ResponseDecoder.swift
//  Networking
//
//  Created by Eryk Mól on 17/11/2026.
//

import Foundation

public struct ResponseDecoder: ResponseDecoderProtocol {
    public init() {}

    public func decode<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws(NetworkError) -> T {
        try await decodeOffTheCallersActor(type, from: data)
    }

    @concurrent
    private func decodeOffTheCallersActor<T: Decodable & Sendable>(_ type: T.Type, from data: Data) async throws(NetworkError) -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw .unexpected("Couldn't decode the data, error: \(String(describing: error))")
        }
    }
}
