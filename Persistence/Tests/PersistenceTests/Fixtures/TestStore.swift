//
//  TestStore.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

final class TestStore {
    let url: URL
    private let directory: URL

    init() throws {
        directory = URL.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appending(path: "Test.sqlite")
    }

    deinit {
        try? FileManager.default.removeItem(at: directory)
    }

    func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path(percentEncoded: false))
    }

    func seed(_ model: NSManagedObjectModel, entity: String = TestEntity.item, with objects: [[String: Any]]) throws {
        try withContext(model) { context in
            for values in objects {
                NSEntityDescription
                    .insertNewObject(forEntityName: entity, into: context)
                    .setValuesForKeys(values)
            }
            try context.save()
        }
    }

    func items(_ model: NSManagedObjectModel) throws -> [TestItem] {
        try withContext(model) { context in
            let request = NSFetchRequest<NSManagedObject>(entityName: TestEntity.item)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            return try context.fetch(request).map { TestItem($0) }
        }
    }

    func tagNames(_ model: NSManagedObjectModel) throws -> [String] {
        try withContext(model) { context in
            let request = NSFetchRequest<NSManagedObject>(entityName: TestEntity.tag)
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            return try context.fetch(request).compactMap { $0.value(forKey: "name") as? String }
        }
    }

    func seedOwner(named ownerName: String, withPetNamed petName: String, in model: NSManagedObjectModel) throws {
        try withContext(model) { context in
            let owner = NSEntityDescription.insertNewObject(forEntityName: RelationTestEntity.owner, into: context)
            owner.setValue(ownerName, forKey: "name")
            let pet = NSEntityDescription.insertNewObject(forEntityName: RelationTestEntity.pet, into: context)
            pet.setValue(petName, forKey: "name")
            pet.setValue(owner, forKey: "owner")
            try context.save()
        }
    }

    func petOwnerNames(_ model: NSManagedObjectModel) throws -> [String] {
        try withContext(model) { context in
            try context
                .fetch(NSFetchRequest<NSManagedObject>(entityName: RelationTestEntity.pet))
                .map { ($0.value(forKeyPath: "owner.name") as? String) ?? "" }
        }
    }

    func isOn(_ model: NSManagedObjectModel) throws -> Bool {
        let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: url, options: nil)
        return model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
    }

    private func withContext<Value>(
        _ model: NSManagedObjectModel,
        _ body: (NSManagedObjectContext) throws -> Value
    ) throws -> Value {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: url)
        defer { try? coordinator.remove(store) }

        let context = NSManagedObjectContext(.privateQueue)
        context.persistentStoreCoordinator = coordinator
        // `performAndWait` runs the closure synchronously, so handing the non-Sendable
        // `body` and `context` to its `@Sendable` block is safe.
        return try withoutActuallyEscaping(body) { body in
            nonisolated(unsafe) let body = body
            return try context.performAndWait { try body(context) }
        }
    }
}
