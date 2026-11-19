//
//  RequestBuilderTests.swift
//  Networking
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Networking

struct RequestBuilderTests {
    private static let baseURL = URL(staticString: "https://api.example.com/")

    @Test func appendsThePathToTheBaseURL() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)

        let request = try sut.makeRequest(for: Endpoint(method: .GET, path: "v1/items"))

        #expect(request.url?.absoluteString == "https://api.example.com/v1/items")
    }

    @Test func keepsThePathOfTheBaseURL() throws {
        let sut = RequestBuilder(baseURL: URL(staticString: "https://api.example.com/api/"))

        let request = try sut.makeRequest(for: Endpoint(method: .GET, path: "v1/items"))

        #expect(request.url?.path() == "/api/v1/items")
    }

    @Test func addsTheQueryItems() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)
        let endpoint = Endpoint(method: .GET, path: "v1/items", query: [
            URLQueryItem(name: "first", value: "1"),
            URLQueryItem(name: "second", value: "2"),
        ])

        let request = try sut.makeRequest(for: endpoint)

        #expect(request.url?.query() == "first=1&second=2")
    }

    @Test func percentEncodesNonASCIICharactersInTheQuery() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)
        let endpoint = Endpoint(method: .GET, path: "v1/items", query: [URLQueryItem(name: "key", value: "café")])

        let request = try sut.makeRequest(for: endpoint)

        #expect(request.url?.query() == "key=caf%C3%A9")
    }

    @Test func leavesOutTheQueryWhenThereAreNoItems() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)

        let request = try sut.makeRequest(for: Endpoint(method: .GET, path: "v1/items"))

        #expect(request.url?.query() == nil)
    }

    @Test func setsTheMethodAndBody() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)
        let body = Data(#"{"key":"value"}"#.utf8)

        let request = try sut.makeRequest(for: Endpoint(method: .POST, path: "v1/items", body: body))

        #expect(request.httpMethod == "POST")
        #expect(request.httpBody == body)
    }

    @Test func asksForJSONByDefault() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)

        let request = try sut.makeRequest(for: Endpoint(method: .GET, path: "v1/items"))

        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func addsTheEndpointHeaders() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)
        let endpoint = Endpoint(method: .POST, path: "v1/items", headers: ["Content-Type": "application/json"])

        let request = try sut.makeRequest(for: endpoint)

        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test func endpointHeadersOverrideTheDefaultAccept() throws {
        let sut = RequestBuilder(baseURL: Self.baseURL)
        let endpoint = Endpoint(method: .GET, path: "v1/export", headers: ["Accept": "text/csv"])

        let request = try sut.makeRequest(for: endpoint)

        #expect(request.value(forHTTPHeaderField: "Accept") == "text/csv")
    }
}
