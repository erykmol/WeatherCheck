//
//  CoreDataStackTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence

@MainActor
struct CoreDataStackTests {
    @Test func inMemoryStacksDoNotShareData() throws {
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .inMemory)
        let other = try CoreDataStack(plan: TestMigrationPlan.self, storage: .inMemory)
        try insertItem(titled: "Apples", into: other)

        let titles = try itemTitles(in: sut)

        #expect(titles.isEmpty)
    }

    @Test func keepsSavedDataInTheStoreFile() throws {
        let store = try TestStore()
        let writer = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        try insertItem(titled: "Apples", into: writer)
        try writer.close()
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let titles = try itemTitles(in: sut)

        #expect(titles == ["Apples"])
    }

    @Test func migratesAnOlderStoreWhenOpeningIt() throws {
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let items = try sut.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: TestEntity.item)).map { TestItem($0) }

        #expect(items == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs")])
    }

    @Test func deletingTheStoreFilesRemovesItsData() throws {
        let store = try TestStore()
        let writer = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        try insertItem(titled: "Apples", into: writer)
        try writer.close()

        try CoreDataStack.deleteStoreFiles(at: store.url)

        let reopened = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? reopened.close() }
        #expect(try itemTitles(in: reopened).isEmpty)
    }

    @Test func deletesTheJournalFilesWithTheStore() throws {
        let store = try TestStore()
        let files = ["", "-wal", "-shm"].map { URL(filePath: store.url.path(percentEncoded: false) + $0) }
        for file in files {
            try Data("not a database".utf8).write(to: file)
        }

        try CoreDataStack.deleteStoreFiles(at: store.url)

        #expect(files.allSatisfy { !store.fileExists(at: $0) })
    }

    @Test func deletingMissingStoreFilesDoesNothing() throws {
        let store = try TestStore()

        try CoreDataStack.deleteStoreFiles(at: store.url)

        #expect(!store.fileExists(at: store.url))
    }

    @Test func rejectsAnInvalidPlan() {
        let error = #expect(throws: MigrationError.self) {
            try CoreDataStack(plan: EmptyTestMigrationPlan.self, storage: .inMemory)
        }

        let isInvalidPlan = switch error {
        case .invalidPlan?:
            true
        default:
            false
        }
        #expect(isInvalidPlan)
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
