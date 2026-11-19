//
//  NetworkingManagerTests.swift
//  Networking
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking
import NetworkingTestHelpers

struct NetworkingManagerTests {
    private func makeSUT(session: StubURLSession) -> NetworkingManager {
        NetworkingManager(
            builder: RequestBuilder(baseURL: URL(staticString: "https://api.example.com/")),
            session: session,
            errorMessage: { data in
                return try? JSONDecoder().decode(ErrorBody.self, from: data).message
            }
        )
    }

    @Test func sendsTheRequestBuiltFromTheEndpoint() async throws {
        let session = StubURLSession { request in
            (.stub(200, for: request), Data((request.url?.absoluteString ?? "").utf8))
        }
        let sut = makeSUT(session: session)

        let data = try await sut.send(Endpoint(
            method: .GET,
            path: "v1/items",
            query: [URLQueryItem(name: "key", value: "value")]
        ))

        #expect(String(decoding: data, as: UTF8.self) == "https://api.example.com/v1/items?key=value")
    }

    @Test func returnsTheBodyOfASuccessfulResponse() async throws {
        let body = Data(#"{"key":"value"}"#.utf8)
        let session = StubURLSession { request in (.stub(200, for: request), body) }
        let sut = makeSUT(session: session)

        let data = try await sut.send(Endpoint(method: .GET, path: "v1/items"))

        #expect(data == body)
    }

    @Test func mapsAnErrorBodyToItsMessage() async {
        let session = StubURLSession { request in
            (.stub(400, for: request), Data(#"{"message":"Something went wrong"}"#.utf8))
        }
        let sut = makeSUT(session: session)

        await #expect(throws: NetworkError.http(status: 400, message: "Something went wrong")) {
            try await sut.send(Endpoint(method: .GET, path: "v1/items"))
        }
    }

    @Test func leavesTheMessageEmptyWhenTheErrorBodyIsUnreadable() async {
        let session = StubURLSession { request in
            (.stub(502, for: request), Data("<html>Bad Gateway</html>".utf8))
        }
        let sut = makeSUT(session: session)

        await #expect(throws: NetworkError.http(status: 502, message: nil)) {
            try await sut.send(Endpoint(method: .GET, path: "v1/items"))
        }
    }

    @Test func mapsNoConnectionToOffline() async {
        let session = StubURLSession { _ in throw URLError(.notConnectedToInternet) }
        let sut = makeSUT(session: session)

        await #expect(throws: NetworkError.offline) {
            try await sut.send(Endpoint(method: .GET, path: "v1/items"))
        }
    }

    @Test func mapsOtherSessionFailuresToUnexpected() async {
        let session = StubURLSession { _ in throw URLError(.timedOut) }
        let sut = makeSUT(session: session)

        let error = await #expect(throws: NetworkError.self) {
            try await sut.send(Endpoint(method: .GET, path: "v1/items"))
        }

        let isUnexpected = switch error {
        case .unexpected?:
            true
        default:
            false
        }
        
        #expect(isUnexpected)
    }
}

private struct ErrorBody: Decodable {
    let message: String
}
