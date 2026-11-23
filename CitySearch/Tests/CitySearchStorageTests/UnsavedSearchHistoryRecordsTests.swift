//
//  UnsavedSearchHistoryRecordsTests.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import Testing
import CitySearch
@testable import CitySearchStorage

@MainActor
struct UnsavedSearchHistoryRecordsTests {
    private let sut = UnsavedSearchHistoryRecords()
    private let entry = SearchHistoryEntry(
        city: City(id: 1, name: "Łódź", region: nil, country: nil, latitude: 0.0, longitude: 0.0),
        searchedAt: Date(timeIntervalSinceReferenceDate: 0.0)
    )

    @Test func startsEmpty() {
        #expect(sut.loadEntries().isEmpty)
    }

    @Test func staysEmptyAfterSave() {
        sut.save(entry)

        #expect(sut.loadEntries().isEmpty)
    }
}
