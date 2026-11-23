//
//  RequestBuilder.swift
//  Networking
//
//  Created by Eryk Mól on 16/11/2026.
//

import Foundation

public struct RequestBuilder: Sendable {
    private let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    public func makeRequest(
        for endpoint: Endpoint
    ) throws(NetworkError) -> URLRequest {
        var components = URLComponents(url: baseURL.appending(path: endpoint.path), resolvingAgainstBaseURL: false)
        
        if !endpoint.query.isEmpty {
            components?.queryItems = endpoint.query
            let plusEncodedQuery = components?.percentEncodedQuery?
                .replacingOccurrences(of: Constants.plus, with: Constants.encodedPlus)
            components?.percentEncodedQuery = plusEncodedQuery
        }
        
        guard let url = components?.url else {
            throw .unexpected("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.cachePolicy = endpoint.ignoresCache ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        for (field, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        return request
    }
}

private enum Constants {
    static let plus = "+"
    static let encodedPlus = "%2B"
}
