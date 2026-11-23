//
//  OpenMeteoErrorDecoder.swift
//  Forecast
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

struct OpenMeteoErrorDecoder {
    func decodeReason(from data: Data) -> String? {
        try? JSONDecoder().decode(OpenMeteoErrorBody.self, from: data).reason
    }
}
