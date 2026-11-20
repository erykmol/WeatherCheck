//
//  NetworkingManager.swift
//  Networking
//
//  Created by Eryk Mól on 16/11/2026.
//

import Foundation

public struct NetworkingManager: NetworkingManagerProtocol {
    private let builder: RequestBuilder
    private let session: any URLSessionProtocol
    
    private let errorMessage: @Sendable (Data) -> String?

    public init(
        builder: RequestBuilder,
        session: any URLSessionProtocol = URLSession.shared,
        errorMessage: @escaping @Sendable (Data) -> String? = { _ in nil }
    ) {
        self.builder = builder
        self.session = session
        self.errorMessage = errorMessage
    }

    @discardableResult
    public func send(_ endpoint: Endpoint) async throws(NetworkError) -> Data {
        try await perform(builder.makeRequest(for: endpoint))
    }

    private func perform(_ request: URLRequest) async throws(NetworkError) -> Data {
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw .unexpected("Not an HTTP response")
        }
        
        switch http.statusCode {
        case 200..<300:
            return data
        default:
            throw .http(status: http.statusCode, message: errorMessage(data))
        }
    }
}
