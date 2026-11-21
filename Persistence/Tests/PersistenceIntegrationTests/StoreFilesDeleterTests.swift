//
//  StoreFilesDeleterTests.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence
import PersistenceTestHelpers
import PersistenceTestFixtures

@MainActor
struct StoreFilesDeleterTests {
    @Test func deletingTheStoreFilesRemovesItsData() throws {
        let store = try TestStore()
        let factory = CoreDataStackFactory(plan: TestMigrationPlan.self)
        let writer = try factory.makeStack(storage: .file(store.url))
        try insertItem(titled: "Apples", into: writer)
        try writer.close()
        let sut = StoreFilesDeleter()

        try sut.deleteStoreFiles(at: store.url)

        let reopened = try factory.makeStack(storage: .file(store.url))
        defer { try? reopened.close() }
        #expect(try itemTitles(in: reopened).isEmpty)
    }

    @Test func deletesTheJournalFilesWithTheStore() throws {
        let store = try TestStore()
        let files = ["", "-wal", "-shm"].map { URL(filePath: store.url.path(percentEncoded: false) + $0) }
        for file in files {
            try Data("not a database".utf8).write(to: file)
        }
        let sut = StoreFilesDeleter()

        try sut.deleteStoreFiles(at: store.url)

        #expect(files.allSatisfy { !store.fileExists(at: $0) })
    }

    @Test func deletingMissingStoreFilesDoesNothing() throws {
        let store = try TestStore()
        let sut = StoreFilesDeleter()

        try sut.deleteStoreFiles(at: store.url)

        #expect(!store.fileExists(at: store.url))
    }

    private func insertItem(titled title: String, into stack: CoreDataStack) throws {
        NSEntityDescription
            .insertNewObject(forEntityName: TestEntity.item, into: stack.viewContext)
            .setValue(title, forKey: "title")
        try stack.viewContext.save()
    }

    private func itemTitles(in stack: CoreDataStack) throws -> [String] {
        try stack.viewContext
            .fetch(NSFetchRequest<NSManagedObject>(entityName: TestEntity.item))
            .compactMap { $0.value(forKey: "title") as? String }
    }
}
