//
//  SearchHistoryStackOpenerTests.swift
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
struct SearchHistoryStackOpenerTests {
    @Test func keepsAStoreThatOpens() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        let factory = CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self)
        let writer = try factory.makeStack(storage: .file(url))
        try SearchHistoryStore(stack: writer, retention: SearchHistoryRetention(), now: { .now }).record(.lodz)
        try writer.close()
        let sut = SearchHistoryStackOpener(factory: factory)

        let stack = try sut.openStack(storage: .file(url))
        defer { try? stack.close() }

        let history = SearchHistoryStore(stack: stack, retention: SearchHistoryRetention(), now: { .now })
        #expect(try history.load() == [.lodz])
    }

    // Logs "starting a new one: unknownStoreVersion" error on purpose.
    @Test func startsANewStoreWhenTheStoreHasAnUnknownSchema() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try writeStoreWithUnknownSchema(at: url)
        let sut = SearchHistoryStackOpener(factory: CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self))

        let stack = try sut.openStack(storage: .file(url))
        defer { try? stack.close() }

        #expect(try storeMatchesTheModel(of: stack, at: url))
    }

    // Core Data's "file is not a database" errors and "starting a new one: unreadableStore" are logged on purpose.
    @Test func startsANewStoreWhenTheStoreFileIsDamaged() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try writeDamagedStore(at: url)
        let sut = SearchHistoryStackOpener(factory: CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self))

        let stack = try sut.openStack(storage: .file(url))
        defer { try? stack.close() }

        #expect(try storeMatchesTheModel(of: stack, at: url))
    }

    @Test func keepsTheStoreFileWhenThePlanIsInvalid() throws {
        let url = temporaryStoreURL()
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }
        try writeDamagedStore(at: url)
        let sut = SearchHistoryStackOpener(factory: CoreDataStackFactory(plan: EmptyMigrationPlan.self))

        #expect(throws: MigrationError.self) {
            _ = try sut.openStack(storage: .file(url))
        }

        #expect(FileManager.default.fileExists(atPath: url.path(percentEncoded: false)))
    }

    private func temporaryStoreURL() -> URL {
        URL.temporaryDirectory.appending(path: UUID().uuidString).appending(path: "SearchHistory.sqlite")
    }

    private func storeMatchesTheModel(of stack: CoreDataStack, at url: URL) throws -> Bool {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: url, options: nil)
        let model = stack.viewContext.persistentStoreCoordinator?.managedObjectModel
        return model?.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) == true
    }

    private func writeStoreWithUnknownSchema(at url: URL) throws {
        let model = NSManagedObjectModel()
        model.entities = [
            NSEntityDescription(
                name: "Unknown",
                properties: [NSAttributeDescription(name: "value", type: .stringAttributeType, isOptional: true)]
            ),
        ]
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try coordinator.remove(coordinator.addPersistentStore(type: .sqlite, at: url))
    }

    private func writeDamagedStore(at url: URL) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not a database".utf8).write(to: url)
    }
}

private enum EmptyMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        []
    }

    static var stages: [MigrationStage] {
        []
    }
}
