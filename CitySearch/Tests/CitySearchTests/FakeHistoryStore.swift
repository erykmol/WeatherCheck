//
//  FakeHistoryStore.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
@testable import CitySearch

@MainActor
final class FakeHistoryStore: SearchHistoryStoreProtocol {
    private var cities: [City]

    init(cities: [City] = []) {
        self.cities = cities
    }

    func load() -> [City] {
        cities
    }

    func record(_ city: City) {
        remove(city)
        cities.insert(city, at: 0)
    }

    func remove(_ city: City) {
        cities.removeAll { $0.id == city.id }
    }

    func removeAll() {
        cities.removeAll()
    }
}
