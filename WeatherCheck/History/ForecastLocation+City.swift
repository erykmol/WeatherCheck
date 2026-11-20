//
//  ForecastLocation+City.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import CitySearch
import Forecast

extension ForecastLocation {
    init(_ city: City) {
        self.init(
            name: city.name,
            subtitle: city.subtitle,
            latitude: city.latitude,
            longitude: city.longitude
        )
    }
}
