//
//  SearchHistoryStoreTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence
@testable import CitySearch

@MainActor
struct SearchHistoryStoreTests {
    private func makeStack() throws -> CoreDataStack {
        try CoreDataStack(plan: SearchHistoryMigrationPlan.self, storage: .inMemory)
    }

    private func makeSUT(
        retention: SearchHistoryRetention = SearchHistoryRetention(),
        now: @escaping () -> Date = { .now }
    ) throws -> SearchHistoryStore {
        try SearchHistoryStore(stack: makeStack(), retention: retention, now: now)
    }

    @Test func startsEmpty() throws {
        let sut = try makeSUT()

        #expect(try sut.load().isEmpty)
    }

    @Test func listsTheLatestSearchFirst() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let sut = try makeSUT(now: { now })
        try sut.record(.krakow)
        now += 60

        try sut.record(.lodz)

        #expect(try sut.load() == [.lodz, .krakow])
    }

    @Test func movesARepeatedCityToTheTopWithoutDuplicatingIt() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let sut = try makeSUT(now: { now })
        try sut.record(.lodz)
        now += 60
        try sut.record(.krakow)
        now += 60

        try sut.record(.lodz)

        #expect(try sut.load() == [.lodz, .krakow])
    }

    @Test func keepsMissingRegionAndCountryMissing() throws {
        let sut = try makeSUT()

        try sut.record(.withoutRegionOrCountry)

        #expect(try sut.load() == [.withoutRegionOrCountry])
    }

    @Test func updatesTheDetailsOfARecordedCity() throws {
        let sut = try makeSUT()
        try sut.record(.lodz)
        let updated = City(id: City.lodz.id, name: "Lodz", region: nil, country: "Poland", latitude: 51.76, longitude: 19.46)

        try sut.record(updated)

        #expect(try sut.load() == [updated])
    }

    @Test func removesOneCity() throws {
        let sut = try makeSUT()
        try sut.record(.lodz)
        try sut.record(.krakow)

        try sut.remove(.lodz)

        #expect(try sut.load() == [.krakow])
    }

    @Test func removingAllClearsTheHistory() throws {
        let sut = try makeSUT()
        try sut.record(.lodz)
        try sut.record(.krakow)

        try sut.removeAll()

        #expect(try sut.load().isEmpty)
    }

    @Test func listsOnlyTheLatestCitiesUpToTheMaximumCount() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let sut = try makeSUT(retention: SearchHistoryRetention(maxCount: 2), now: { now })

        for id in 1...3 {
            try sut.record(.numbered(id))
            now += 60
        }

        #expect(try sut.load() == [.numbered(3), .numbered(2)])
    }

    @Test func leavesOutCitiesSearchedBeforeTheMaximumAge() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let sut = try makeSUT(retention: SearchHistoryRetention(maxAge: 3_600), now: { now })
        try sut.record(.krakow)
        now += 1_800
        try sut.record(.lodz)

        now += 2_400

        #expect(try sut.load() == [.lodz])
    }

    @Test func deletesCitiesBeyondTheMaximumCount() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let stack = try makeStack()
        let sut = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(maxCount: 2), now: { now })

        for id in 1...3 {
            try sut.record(.numbered(id))
            now += 60
        }

        let everything = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(), now: { now })
        #expect(try everything.load() == [.numbered(3), .numbered(2)])
    }

    @Test func deletesCitiesOlderThanTheMaximumAge() throws {
        var now = Date(timeIntervalSinceReferenceDate: 0)
        let stack = try makeStack()
        let sut = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(maxAge: 3_600), now: { now })
        try sut.record(.krakow)
        now += 7_200

        try sut.record(.lodz)

        let everything = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(), now: { now })
        #expect(try everything.load() == [.lodz])
    }

    @Test func keepsTheHistoryInTheStoreFile() throws {
        let url = URL.temporaryDirectory.appending(path: UUID().uuidString).appending(path: "SearchHistory.sqlite")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let factory = CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self)
        let writerStack = try factory.makeStack(storage: .file(url))
        defer { try? writerStack.close() }
        try SearchHistoryStore(stack: writerStack, retention: SearchHistoryRetention(), now: { .now }).record(.lodz)
        let stack = try factory.makeStack(storage: .file(url))
        defer { try? stack.close() }
        let sut = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(), now: { .now })

        let cities = try sut.load()

        #expect(cities == [.lodz])
    }
}
