//
//  Destination.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import CitySearch
import Navigation

nonisolated enum Destination: NavigationDestinationProtocol {
    case forecast(City)

    var presentation: NavigationPresentation {
        switch self {
        case .forecast: .push
        }
    }
}
