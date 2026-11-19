//
//  CoreDataStack.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@MainActor
public final class CoreDataStack {
    public enum Storage: Sendable {
        case file(URL)
        case inMemory

        public static func applicationSupport(fileName: String) -> Storage {
            .file(.applicationSupportDirectory.appending(path: fileName))
        }
    }

    public let viewContext: NSManagedObjectContext
    private let container: NSPersistentContainer

    public init(plan: MigrationPlan.Type, storage: Storage) throws {
        let model = try MigrationStepBuilder.currentModel(of: plan)
        let storeURL = try Self.prepareStore(for: storage, plan: plan, model: model)

        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = false

        let container = NSPersistentContainer(name: String(describing: plan), managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        try Self.loadStores(of: container)

        self.container = container
        viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    public func close() throws {
        viewContext.reset()
        let coordinator = container.persistentStoreCoordinator
        for store in coordinator.persistentStores {
            try coordinator.remove(store)
        }
    }

    public static func deleteStoreFiles(at url: URL) throws {
        for suffix in Constants.storeFileSuffixes {
            let file = URL(filePath: url.path(percentEncoded: false) + suffix)
            if FileManager.default.fileExists(atPath: file.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: file)
            }
        }
    }

    private static func prepareStore(
        for storage: Storage,
        plan: MigrationPlan.Type,
        model: NSManagedObjectModel
    ) throws -> URL {
        switch storage {
        case .file(let url):
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try ProgressiveMigrator(currentModel: model).migrateStoreIfNeeded(at: url) { () throws(MigrationError) in
                try MigrationStepBuilder.steps(for: plan)
            }
            return url
        case .inMemory:
            return URL(filePath: Constants.inMemoryPath)
        }
    }

    private static func loadStores(of container: NSPersistentContainer) throws {
        var loadError: (any Error)?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        if let loadError {
            throw loadError
        }
    }
}

private enum Constants {
    static let inMemoryPath = "/dev/null"
    static let storeFileSuffixes = ["", "-wal", "-shm"]
}
