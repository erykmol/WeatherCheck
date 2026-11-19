//
//  URLSession+Extensions.swift
//  Networking
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

extension URLSession: URLSessionProtocol {
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: nil)
    }
}
