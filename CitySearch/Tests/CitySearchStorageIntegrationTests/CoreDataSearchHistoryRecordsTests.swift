//
//  CoreDataSearchHistoryRecordsTests.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
import Persistence
import CitySearch
@testable import CitySearchStorage

@MainActor
struct CoreDataSearchHistoryRecordsTests {
    private let searchedAt = Date(timeIntervalSinceReferenceDate: 0)

    private func makeSUT() throws -> CoreDataSearchHistoryRecords {
        try CoreDataSearchHistoryRecords(storage: .inMemory)
    }

    @Test func startsEmpty() throws {
        let sut = try makeSUT()

        #expect(try sut.entries().isEmpty)
    }

    @Test func savesAnEntry() throws {
        let sut = try makeSUT()
        let entry = SearchHistoryEntry(city: .lodz, searchedAt: searchedAt)

        try sut.save(entry)

        #expect(try sut.entries() == [entry])
    }

    @Test func replacesTheEntryOfTheSameCity() throws {
        let sut = try makeSUT()
        try sut.save(SearchHistoryEntry(city: .lodz, searchedAt: searchedAt))
        let updated = City(id: City.lodz.id, name: "Lodz", region: nil, country: "Poland", latitude: 51.76, longitude: 19.46)
        let entry = SearchHistoryEntry(city: updated, searchedAt: searchedAt + 60)

        try sut.save(entry)

        #expect(try sut.entries() == [entry])
    }

    @Test func keepsMissingRegionAndCountryMissing() throws {
        let sut = try makeSUT()
        let entry = SearchHistoryEntry(city: .withoutRegionOrCountry, searchedAt: searchedAt)

        try sut.save(entry)

        #expect(try sut.entries() == [entry])
    }

    @Test func deletesTheEntriesOfTheGivenCities() throws {
        let sut = try makeSUT()
        try sut.save(SearchHistoryEntry(city: .lodz, searchedAt: searchedAt))
        let krakow = SearchHistoryEntry(city: .krakow, searchedAt: searchedAt)
        try sut.save(krakow)

        try sut.delete(cityIDs: [City.lodz.id])

        #expect(try sut.entries() == [krakow])
    }

    @Test func deletesAllEntries() throws {
        let sut = try makeSUT()
        try sut.save(SearchHistoryEntry(city: .lodz, searchedAt: searchedAt))
        try sut.save(SearchHistoryEntry(city: .krakow, searchedAt: searchedAt))

        try sut.deleteAll()

        #expect(try sut.entries().isEmpty)
    }

    @Test func keepsTheEntriesInTheStoreFile() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let factory = CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self)
        let writerStack = try factory.makeStack(storage: .file(url))
        defer { try? writerStack.close() }
        let entry = SearchHistoryEntry(city: .lodz, searchedAt: searchedAt)
        try CoreDataSearchHistoryRecords(stack: writerStack).save(entry)
        let stack = try factory.makeStack(storage: .file(url))
        defer { try? stack.close() }
        let sut = CoreDataSearchHistoryRecords(stack: stack)

        let entries = try sut.entries()

        #expect(entries == [entry])
    }

    // Core Data's "file is not a database" errors and "starting a new one: unreadableStore" are logged on purpose.
    @Test func startsANewStoreWhenTheStoreFileIsDamaged() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not a database".utf8).write(to: url)
        let opener = SearchHistoryStackOpener(factory: CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self))
        let stack = try opener.openStack(storage: .file(url))
        defer { try? stack.close() }
        let sut = CoreDataSearchHistoryRecords(stack: stack)
        let entry = SearchHistoryEntry(city: .lodz, searchedAt: searchedAt)

        try sut.save(entry)

        #expect(try sut.entries() == [entry])
    }

    private func temporaryStoreURL() -> URL {
        URL.temporaryDirectory.appending(path: UUID().uuidString).appending(path: "SearchHistory.sqlite")
    }
}
