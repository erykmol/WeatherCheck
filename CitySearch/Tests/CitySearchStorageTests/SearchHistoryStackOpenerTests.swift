//
//  SearchHistoryStackOpenerTests.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import Persistence
@testable import CitySearchStorage

@MainActor
struct SearchHistoryStackOpenerTests {
    private let url = URL(filePath: "/history/SearchHistory.sqlite")

    @Test func keepsAStoreThatOpens() throws {
        let factory = FakeStackFactory(results: [.success("stored")])
        let sut = SearchHistoryStackOpener(factory: factory)

        let stack = try sut.openStack(storage: .file(url))

        #expect(stack == "stored")
        #expect(factory.deletedURLs.isEmpty)
    }

    @Test(arguments: [
        MigrationError.unknownStoreVersion,
        .unreadableStore(underlying: TestFailure()),
        .stepFailed(step: 0, underlying: TestFailure()),
        .incompleteMigration,
    ])
    func startsANewStoreWhenTheStoreCantBeOpened(error: MigrationError) throws {
        let factory = FakeStackFactory(results: [.failure(error), .success("new")])
        let sut = SearchHistoryStackOpener(factory: factory)

        let stack = try sut.openStack(storage: .file(url))

        #expect(stack == "new")
        #expect(factory.deletedURLs == [url])
    }

    @Test func keepsTheStoreFilesWhenThePlanIsInvalid() {
        let factory = FakeStackFactory(results: [.failure(.invalidPlan(reason: "The plan has no schemas"))])
        let sut = SearchHistoryStackOpener(factory: factory)

        #expect(throws: MigrationError.self) {
            _ = try sut.openStack(storage: .file(url))
        }

        #expect(factory.deletedURLs.isEmpty)
    }

    @Test func doesNotStartOverAnInMemoryStore() {
        let factory = FakeStackFactory(results: [.failure(.unknownStoreVersion)])
        let sut = SearchHistoryStackOpener(factory: factory)

        #expect(throws: MigrationError.self) {
            _ = try sut.openStack(storage: .inMemory)
        }

        #expect(factory.deletedURLs.isEmpty)
    }
}

private struct TestFailure: Error {}
