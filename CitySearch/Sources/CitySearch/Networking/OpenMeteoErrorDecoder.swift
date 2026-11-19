//
//  OpenMeteoErrorDecoder.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

struct OpenMeteoErrorDecoder {
    func reason(from data: Data) -> String? {
        try? JSONDecoder().decode(OpenMeteoErrorBody.self, from: data).reason
    }
}
