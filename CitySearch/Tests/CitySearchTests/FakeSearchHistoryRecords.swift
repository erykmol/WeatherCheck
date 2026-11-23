//
//  FakeSearchHistoryRecords.swift
//  CitySearch
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
@testable import CitySearch

@MainActor
final class FakeSearchHistoryRecords: SearchHistoryRecordsProtocol {
    private var stored: [Int: SearchHistoryEntry] = [:]

    func loadEntries() -> [SearchHistoryEntry] {
        Array(stored.values)
    }

    func save(_ entry: SearchHistoryEntry) {
        stored[entry.city.id] = entry
    }

    func delete(cityIDs: [Int]) {
        for id in cityIDs {
            stored[id] = nil
        }
    }

    func deleteAll() {
        stored.removeAll()
    }
}
