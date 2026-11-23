//
//  FakeSearchHistoryRecords.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import CitySearch

@MainActor
final class FakeSearchHistoryRecords: SearchHistoryRecordsProtocol {
    let name: String

    init(name: String) {
        self.name = name
    }

    func loadEntries() -> [SearchHistoryEntry] {
        []
    }

    func save(_ entry: SearchHistoryEntry) {}

    func delete(cityIDs: [Int]) {}

    func deleteAll() {}
}
