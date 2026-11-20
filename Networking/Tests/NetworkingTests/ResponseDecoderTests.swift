//
//  ResponseDecoderTests.swift
//  Networking
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
import Networking

struct ResponseDecoderTests {
    @Test func decodesTheValue() async throws {
        let sut = ResponseDecoder()

        let item = try await sut.decode(Item.self, from: Data(#"{"name":"Łódź"}"#.utf8))

        #expect(item == Item(name: "Łódź"))
    }

    @Test func mapsUnreadableDataToUnexpected() async {
        let sut = ResponseDecoder()

        let error = await #expect(throws: NetworkError.self) {
            try await sut.decode(Item.self, from: Data("<html>Bad Gateway</html>".utf8))
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

private struct Item: Decodable, Equatable, Sendable {
    let name: String
}
