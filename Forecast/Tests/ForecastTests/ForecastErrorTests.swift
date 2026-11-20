//
//  ForecastErrorTests.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
import Networking
@testable import Forecast

private let errors: [(NetworkError, ForecastError)] = [
    (.offline, .offline),
    (.http(status: 400, message: "Latitude must be in range of -90 to 90°."), .server(message: "Latitude must be in range of -90 to 90°.")),
    (.http(status: 502, message: nil), .server(message: nil)),
    (.unexpected("Couldn't decode the data"), .unknown),
]

struct ForecastErrorTests {
    @Test(arguments: errors)
    func mapsNetworkErrors(error: NetworkError, expected: ForecastError) {
        let sut = ForecastError(error)

        #expect(sut == expected)
    }
}
