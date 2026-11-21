//
//  SearchErrorTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import Testing
import Networking
@testable import CitySearch

private let errors: [(NetworkError, SearchError)] = [
    (.offline, .offline),
    (.http(status: 400, message: "Parameter count must be between 1 and 100."), .server(message: "Parameter count must be between 1 and 100.")),
    (.http(status: 502, message: nil), .server(message: nil)),
    (.unexpected("Couldn't decode the data"), .unknown),
]

struct SearchErrorTests {
    @Test(arguments: errors)
    func mapsNetworkErrors(error: NetworkError, expected: SearchError) {
        let sut = SearchError(error)

        #expect(sut == expected)
    }
}
