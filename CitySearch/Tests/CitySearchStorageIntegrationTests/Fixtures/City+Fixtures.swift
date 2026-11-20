//
//  City+Fixtures.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CitySearch

extension City {
    static let lodz = City(id: 3093133, name: "Łódź", region: "Łódzkie", country: "Polska", latitude: 51.75, longitude: 19.46667)
    static let krakow = City(id: 3094802, name: "Kraków", region: "Małopolskie", country: "Polska", latitude: 50.06143, longitude: 19.93658)
    static let withoutRegionOrCountry = City(id: 1, name: "Bez regionu", region: nil, country: nil, latitude: 0, longitude: 0)
}
