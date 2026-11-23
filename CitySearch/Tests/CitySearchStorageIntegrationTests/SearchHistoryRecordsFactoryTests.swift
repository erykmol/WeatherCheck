//
//  SearchHistoryRecordsFactoryTests.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import Testing
import CitySearch
@testable import CitySearchStorage

@MainActor
struct SearchHistoryRecordsFactoryTests {
    private let sut = SearchHistoryRecordsFactory()

    // "Couldn't open the search history" errors are logged on purpose: a file sits where the store's folder should be created.
    @Test func fallsBackToMemoryWhenTheFileCantBeCreated() throws {
        let directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let blockingFile = directory.appending(path: "Blocked")
        try Data().write(to: blockingFile)
        let url = blockingFile.appending(path: "SearchHistory.sqlite")
        let entry = SearchHistoryEntry(city: .lodz, searchedAt: Date(timeIntervalSinceReferenceDate: 0.0))

        let records = sut.makeRecordsWithMemoryAndUnsavedFallbacks(storage: .file(url))
        try records.save(entry)

        #expect(records is CoreDataSearchHistoryRecords)
        #expect(try records.loadEntries() == [entry])
        #expect(!FileManager.default.fileExists(atPath: url.path(percentEncoded: false)))
    }
}
