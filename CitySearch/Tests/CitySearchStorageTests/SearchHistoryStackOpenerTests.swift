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
        let deleter = FakeStoreFilesDeleter()
        let sut = SearchHistoryStackOpener(factory: factory, deleter: deleter)

        let stack = try sut.openStackRecreatingOnFailure(storage: .file(url))

        #expect(stack == "stored")
        #expect(deleter.deletedURLs.isEmpty)
    }

    @Test(arguments: [
        MigrationError.unknownStoreVersion,
        .unreadableStore(underlying: TestFailure()),
        .stepFailed(step: 0, underlying: TestFailure()),
        .incompleteMigration,
    ])
    func startsANewStoreWhenTheStoreCantBeOpened(error: MigrationError) throws {
        let factory = FakeStackFactory(results: [.failure(error), .success("new")])
        let deleter = FakeStoreFilesDeleter()
        let sut = SearchHistoryStackOpener(factory: factory, deleter: deleter)

        let stack = try sut.openStackRecreatingOnFailure(storage: .file(url))

        #expect(stack == "new")
        #expect(deleter.deletedURLs == [url])
    }

    @Test func keepsTheStoreFilesWhenThePlanIsInvalid() {
        let factory = FakeStackFactory(results: [.failure(.invalidPlan(reason: "The plan has no schemas"))])
        let deleter = FakeStoreFilesDeleter()
        let sut = SearchHistoryStackOpener(factory: factory, deleter: deleter)

        #expect(throws: MigrationError.self) {
            _ = try sut.openStackRecreatingOnFailure(storage: .file(url))
        }

        #expect(deleter.deletedURLs.isEmpty)
    }

    @Test func doesNotStartOverAnInMemoryStore() {
        let factory = FakeStackFactory(results: [.failure(.unknownStoreVersion)])
        let deleter = FakeStoreFilesDeleter()
        let sut = SearchHistoryStackOpener(factory: factory, deleter: deleter)

        #expect(throws: MigrationError.self) {
            _ = try sut.openStackRecreatingOnFailure(storage: .inMemory)
        }

        #expect(deleter.deletedURLs.isEmpty)
    }
}

private struct TestFailure: Error {}
