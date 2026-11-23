//
//  ResponseDecoderProtocol.swift
//  Networking
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

public protocol ResponseDecoderProtocol: Sendable {
    func decode<T: Decodable & Sendable>(
        _ type: T.Type,
        from data: Data
    ) async throws(NetworkError) -> T
}
