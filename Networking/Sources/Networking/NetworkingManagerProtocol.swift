//
//  NetworkingManagerProtocol.swift
//  Networking
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

public protocol NetworkingManagerProtocol: Sendable {
    @discardableResult
    func send(_ endpoint: Endpoint) async throws(NetworkError) -> Data
}
