//
//  URLSessionProtocol.swift
//  Networking
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

public protocol URLSessionProtocol: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
