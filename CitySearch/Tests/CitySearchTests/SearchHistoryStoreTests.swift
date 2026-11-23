//
//  SearchHistoryStoreTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
@testable import CitySearch

@MainActor
struct SearchHistoryStoreTests {
    private func makeSUT(
        records: FakeSearchHistoryRecords = FakeSearchHistoryRecords(),
        retention: SearchHistoryRetention = SearchHistoryRetention(),
        now: @escaping () -> Date = { .now }
    ) -> SearchHistoryStore {
        SearchHistoryStore(records: records, retention: retention, now: now)
    }

    @Test func startsEmpty() throws {
        let sut = makeSUT()

        #expect(try sut.loadCities().isEmpty)
    }

    @Test func listsTheLatestSearchFirst() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let sut = makeSUT(now: { now })
        try sut.saveApplyingRetention(.krakow)
        now += 60.0

        try sut.saveApplyingRetention(.lodz)

        #expect(try sut.loadCities() == [.lodz, .krakow])
    }

    @Test func movesARepeatedCityToTheTopWithoutDuplicatingIt() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let sut = makeSUT(now: { now })
        try sut.saveApplyingRetention(.lodz)
        now += 60.0
        try sut.saveApplyingRetention(.krakow)
        now += 60.0

        try sut.saveApplyingRetention(.lodz)

        #expect(try sut.loadCities() == [.lodz, .krakow])
    }

    @Test func updatesTheDetailsOfARecordedCity() throws {
        let sut = makeSUT()
        try sut.saveApplyingRetention(.lodz)
        let updated = City(id: City.lodz.id, name: "Lodz", region: nil, country: "Poland", latitude: 51.76, longitude: 19.46)

        try sut.saveApplyingRetention(updated)

        #expect(try sut.loadCities() == [updated])
    }

    @Test func removesOneCity() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let sut = makeSUT(now: { now })
        try sut.saveApplyingRetention(.lodz)
        now += 60.0
        try sut.saveApplyingRetention(.krakow)

        try sut.delete(.lodz)

        #expect(try sut.loadCities() == [.krakow])
    }

    @Test func removingAllClearsTheHistory() throws {
        let sut = makeSUT()
        try sut.saveApplyingRetention(.lodz)
        try sut.saveApplyingRetention(.krakow)

        try sut.deleteAll()

        #expect(try sut.loadCities().isEmpty)
    }

    @Test func listsOnlyTheLatestCitiesUpToTheMaximumCount() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let sut = makeSUT(retention: SearchHistoryRetention(maxCount: 2), now: { now })

        for id in 1...3 {
            try sut.saveApplyingRetention(.numbered(id))
            now += 60.0
        }

        #expect(try sut.loadCities() == [.numbered(3), .numbered(2)])
    }

    @Test func leavesOutCitiesSearchedBeforeTheMaximumAge() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let sut = makeSUT(retention: SearchHistoryRetention(maxAge: 3_600.0), now: { now })
        try sut.saveApplyingRetention(.krakow)
        now += 1_800.0
        try sut.saveApplyingRetention(.lodz)

        now += 2_400.0

        #expect(try sut.loadCities() == [.lodz])
    }

    @Test func deletesCitiesBeyondTheMaximumCount() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let records = FakeSearchHistoryRecords()
        let sut = makeSUT(records: records, retention: SearchHistoryRetention(maxCount: 2), now: { now })

        for id in 1...3 {
            try sut.saveApplyingRetention(.numbered(id))
            now += 60.0
        }

        #expect(Set(records.loadEntries().map(\.city)) == [.numbered(3), .numbered(2)])
    }

    @Test func deletesCitiesOlderThanTheMaximumAge() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0.0)
        let records = FakeSearchHistoryRecords()
        let sut = makeSUT(records: records, retention: SearchHistoryRetention(maxAge: 3_600.0), now: { now })
        try sut.saveApplyingRetention(.krakow)
        now += 7_200.0

        try sut.saveApplyingRetention(.lodz)

        #expect(records.loadEntries().map(\.city) == [.lodz])
    }
}
