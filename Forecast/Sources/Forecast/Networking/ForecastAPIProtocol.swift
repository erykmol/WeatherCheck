//
//  ForecastAPIProtocol.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Networking

protocol ForecastAPIProtocol: Sendable {
    func forecast(latitude: Double, longitude: Double) -> Endpoint
}
