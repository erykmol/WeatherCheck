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
import PersistenceTestHelpers
import PersistenceTestFixtures

@MainActor
struct CoreDataStackTests {
    @Test func inMemoryStacksDoNotShareData() throws {
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .inMemory)
        let other = try CoreDataStack(plan: TestMigrationPlan.self, storage: .inMemory)
        try insertItem(titled: "Apples", into: other)

        let titles = try fetchItemTitles(in: sut)

        #expect(titles.isEmpty)
    }

    @Test func keepsSavedDataInTheStoreFile() throws {
        let store = try TestStore()
        let writer = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        try insertItem(titled: "Apples", into: writer)
        try writer.close()
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let titles = try fetchItemTitles(in: sut)

        #expect(titles == ["Apples"])
    }

    @Test func migratesAnOlderStoreWhenOpeningIt() throws {
        let store = try TestStore()
        try store.seed(makeManagedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let items = try sut.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: TestEntity.item)).map { TestItem($0) }

        #expect(items == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs")])
    }

    @Test func keepsEntitiesWithoutAPolicyWhenMigrating() throws {
        let store = try TestStore()
        let source = makeManagedObjectModel(for: TestSchemaV3.self)
        try store.seed(source, with: [["title": "Apples", "amount": "2.5"]])
        try store.seed(source, entity: TestEntity.tag, with: [["name": "Fruit"]])
        let sut = try CoreDataStack(plan: TestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let tags = try sut.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: TestEntity.tag))

        #expect(tags.compactMap { $0.value(forKey: "name") as? String } == ["Fruit"])
    }

    @Test func keepsRelationshipsWhenMigrating() throws {
        let store = try TestStore()
        try store.seedOwner(named: "Ala", withPetNamed: "Burek", in: makeManagedObjectModel(for: RelationTestSchemaV1.self))
        let sut = try CoreDataStack(plan: RelationTestMigrationPlan.self, storage: .file(store.url))
        defer { try? sut.close() }

        let pets = try sut.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: RelationTestEntity.pet))

        #expect(pets.map { $0.value(forKeyPath: "owner.name") as? String } == ["Ala"])
    }

    @Test func namesTheApplicationSupportStoreAfterThePlan() {
        let sut = CoreDataStack.Storage.applicationSupport(for: TestMigrationPlan.self)

        #expect(extractFileURL(of: sut) == URL.applicationSupportDirectory.appending(path: "TestMigrationPlan.sqlite"))
    }

    @Test func givesEveryPlanItsOwnApplicationSupportStore() {
        let sut = CoreDataStack.Storage.applicationSupport(for: TestMigrationPlan.self)
        let other = CoreDataStack.Storage.applicationSupport(for: RelationTestMigrationPlan.self)

        #expect(extractFileURL(of: sut) != extractFileURL(of: other))
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

    private func extractFileURL(of storage: CoreDataStack.Storage) -> URL? {
        switch storage {
        case .file(let url): url
        case .inMemory: nil
        }
    }

    private func insertItem(titled title: String, into stack: CoreDataStack) throws {
        NSEntityDescription
            .insertNewObject(forEntityName: TestEntity.item, into: stack.viewContext)
            .setValue(title, forKey: "title")
        try stack.viewContext.save()
    }

    private func fetchItemTitles(in stack: CoreDataStack) throws -> [String] {
        try stack.viewContext
            .fetch(NSFetchRequest<NSManagedObject>(entityName: TestEntity.item))
            .compactMap { $0.value(forKey: "title") as? String }
    }
}
