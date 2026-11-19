//
//  CoreDataStackFactoryTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence

@MainActor
struct CoreDataStackFactoryTests {
    @Test func makesAStackOnThePlansCurrentSchema() throws {
        let sut = CoreDataStackFactory(plan: TestMigrationPlan.self)

        let stack = try sut.makeStack(storage: .inMemory)

        let model = stack.viewContext.persistentStoreCoordinator?.managedObjectModel
        #expect(model?.versionChecksum == TestSchemaV5.versionChecksum)
    }

    @Test func deletingTheStoreFilesRemovesItsData() throws {
        let store = try TestStore()
        let sut = CoreDataStackFactory(plan: TestMigrationPlan.self)
        let writer = try sut.makeStack(storage: .file(store.url))
        try insertItem(titled: "Apples", into: writer)
        try writer.close()

        try sut.deleteStoreFiles(at: store.url)

        let reopened = try sut.makeStack(storage: .file(store.url))
        defer { try? reopened.close() }
        #expect(try itemTitles(in: reopened).isEmpty)
    }

    @Test func deletesTheJournalFilesWithTheStore() throws {
        let store = try TestStore()
        let files = ["", "-wal", "-shm"].map { URL(filePath: store.url.path(percentEncoded: false) + $0) }
        for file in files {
            try Data("not a database".utf8).write(to: file)
        }
        let sut = CoreDataStackFactory(plan: TestMigrationPlan.self)

        try sut.deleteStoreFiles(at: store.url)

        #expect(files.allSatisfy { !store.fileExists(at: $0) })
    }

    @Test func deletingMissingStoreFilesDoesNothing() throws {
        let store = try TestStore()
        let sut = CoreDataStackFactory(plan: TestMigrationPlan.self)

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
