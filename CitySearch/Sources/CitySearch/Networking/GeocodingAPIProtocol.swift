//
//  GeocodingAPIProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import Networking

protocol GeocodingAPIProtocol: Sendable {
    func search(name: String) -> Endpoint
}
