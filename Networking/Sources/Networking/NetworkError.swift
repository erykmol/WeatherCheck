//
//  NetworkError.swift
//  Networking
//
//  Created by Eryk Mól on 16/11/2026.
//


import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case offline
    case http(status: Int, message: String?)
    case unexpected(String)

    init(_ error: any Error) {
        let errorCodeList: [URLError.Code] = [
            .notConnectedToInternet,
            .networkConnectionLost,
            .dataNotAllowed,
            .internationalRoamingOff
        ]
        
        if let urlError = error as? URLError,
           errorCodeList.contains(urlError.code) {
            self = .offline
        } else {
            self = .unexpected(String(describing: error))
        }
    }
}
