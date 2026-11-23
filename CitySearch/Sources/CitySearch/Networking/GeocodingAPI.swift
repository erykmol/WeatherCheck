//
//  GeocodingAPI.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

struct GeocodingAPI: GeocodingAPIProtocol {
    static let baseURL = URL(staticString: "https://geocoding-api.open-meteo.com/")

    func makeSearchEndpoint(name: String) -> Endpoint {
        Endpoint(
            method: .GET,
            path: "v1/search",
            query: [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "count", value: String(Constants.resultLimit)),
                URLQueryItem(name: "language", value: "pl"),
                URLQueryItem(name: "format", value: "json"),
            ]
        )
    }
}

private enum Constants {
    static let resultLimit = 30
}
