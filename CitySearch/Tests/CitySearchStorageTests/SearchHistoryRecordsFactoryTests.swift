//
//  SearchHistoryRecordsFactoryTests.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import Testing
@testable import CitySearchStorage

@MainActor
struct SearchHistoryRecordsFactoryTests {
    private let url = URL(filePath: "/history/SearchHistory.sqlite")
    private let unsavedRecords = FakeSearchHistoryRecords(name: "unsaved")

    @Test func returnsTheFileRecordsWhenTheFileOpens() {
        let coreDataFactory = FakeCoreDataSearchHistoryRecordsFactory(
            results: [.success(FakeSearchHistoryRecords(name: "file"))]
        )
        let sut = SearchHistoryRecordsFactory(coreDataFactory: coreDataFactory, unsavedRecords: unsavedRecords)

        let records = sut.makeRecordsWithMemoryAndUnsavedFallbacks(storage: .file(url))

        #expect((records as? FakeSearchHistoryRecords)?.name == "file")
        #expect(coreDataFactory.requestedStorages == [.file(url)])
    }

    @Test func fallsBackToMemoryWhenTheFileFails() {
        let coreDataFactory = FakeCoreDataSearchHistoryRecordsFactory(
            results: [.failure(TestFailure()), .success(FakeSearchHistoryRecords(name: "memory"))]
        )
        let sut = SearchHistoryRecordsFactory(coreDataFactory: coreDataFactory, unsavedRecords: unsavedRecords)

        let records = sut.makeRecordsWithMemoryAndUnsavedFallbacks(storage: .file(url))

        #expect((records as? FakeSearchHistoryRecords)?.name == "memory")
        #expect(coreDataFactory.requestedStorages == [.file(url), .inMemory])
    }

    @Test func fallsBackToUnsavedWhenMemoryFailsToo() {
        let coreDataFactory = FakeCoreDataSearchHistoryRecordsFactory(
            results: [.failure(TestFailure()), .failure(TestFailure())]
        )
        let sut = SearchHistoryRecordsFactory(coreDataFactory: coreDataFactory, unsavedRecords: unsavedRecords)

        let records = sut.makeRecordsWithMemoryAndUnsavedFallbacks(storage: .file(url))

        #expect((records as? FakeSearchHistoryRecords)?.name == "unsaved")
        #expect(coreDataFactory.requestedStorages == [.file(url), .inMemory])
    }
}

private struct TestFailure: Error {}
