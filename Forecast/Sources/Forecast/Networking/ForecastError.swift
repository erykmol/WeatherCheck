//
//  ForecastError.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Networking

enum ForecastError: Error, Equatable {
    case offline
    case server(message: String?)
    case unknown

    init(_ error: NetworkError) {
        switch error {
        case .offline:
            self = .offline
        case .http(_, let message):
            self = .server(message: message)
        case .unexpected:
            self = .unknown
        }
    }
}
