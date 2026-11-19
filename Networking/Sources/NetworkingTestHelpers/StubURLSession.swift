//
//  StubURLSession.swift
//  Networking
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

public struct StubURLSession: URLSessionProtocol {
    public typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)

    private let handler: Handler

    public init(handler: @escaping Handler) {
        self.handler = handler
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let (response, data) = try handler(request)
        return (data, response)
    }
}

public extension HTTPURLResponse {
    static func stub(_ status: Int, for request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
