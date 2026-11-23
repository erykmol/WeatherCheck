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

    func loadCities() -> [City] {
        cities
    }

    func saveApplyingRetention(_ city: City) {
        delete(city)
        cities.insert(city, at: 0)
    }

    func delete(_ city: City) {
        cities.removeAll { $0.id == city.id }
    }

    func deleteAll() {
        cities.removeAll()
    }
}
