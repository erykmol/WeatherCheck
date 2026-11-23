//
//  ForecastAPITests.swift
//  Forecast
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import Networking
@testable import Forecast

struct ForecastAPITests {
    @Test func asksForTheGivenCoordinates() {
        let sut = ForecastAPI()

        let endpoint = sut.makeForecastEndpoint(latitude: 51.75, longitude: 19.46667)

        #expect(endpoint.query.contains(URLQueryItem(name: "latitude", value: "51.75")))
        #expect(endpoint.query.contains(URLQueryItem(name: "longitude", value: "19.46667")))
    }

    @Test func asksForLocalTimes() {
        let sut = ForecastAPI()

        let endpoint = sut.makeForecastEndpoint(latitude: 51.75, longitude: 19.46667)

        #expect(endpoint.query.contains(URLQueryItem(name: "timezone", value: "auto")))
    }
}
