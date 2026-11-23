//
//  GeocodingAPIProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import Networking

protocol GeocodingAPIProtocol: Sendable {
    func makeSearchEndpoint(name: String, ignoringCache: Bool) -> Endpoint
}
