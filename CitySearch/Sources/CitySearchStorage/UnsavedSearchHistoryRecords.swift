//
//  UnsavedSearchHistoryRecords.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import CitySearch

@MainActor
struct UnsavedSearchHistoryRecords: SearchHistoryRecordsProtocol {
    func loadEntries() -> [SearchHistoryEntry] {
        []
    }

    func save(_ entry: SearchHistoryEntry) {}

    func delete(cityIDs: [Int]) {}

    func deleteAll() {}
}
