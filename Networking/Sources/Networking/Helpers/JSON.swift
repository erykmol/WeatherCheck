//
//  JSON.swift
//  Networking
//
//  Created by Eryk Mól on 17/11/2026.
//

import Foundation

public enum JSON {
    public static func body(
        _ value: Encodable,
        encoder: JSONEncoder = JSONEncoder()
    ) throws(NetworkError) -> Data {
        do {
            return try encoder.encode(value)
        } catch {
            throw .unexpected("Couldn't encode the value, error: \(String(describing: error))")
        }
    }
    
    @concurrent
    public static func decode<T: Decodable & Sendable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws(NetworkError) -> T {
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw .unexpected("Couldn't decode the data, error: \(String(describing: error))")
        }
    }
}
