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

    public convenience init(plan: any MigrationPlanProtocol.Type, storage: Storage) throws {
        try self.init(
            name: String(describing: plan),
            stepBuilder: MigrationStepBuilder(plan: plan, modelCache: .shared),
            migrator: ProgressiveMigrator(),
            storage: storage
        )
    }

    init(
        name: String,
        stepBuilder: MigrationStepBuilder,
        migrator: ProgressiveMigrator,
        storage: Storage
    ) throws {
        let model = stepBuilder.currentModel
        let storeURL = try Self.prepareStore(for: storage, model: model, stepBuilder: stepBuilder, migrator: migrator)

        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = false

        let container = NSPersistentContainer(name: name, managedObjectModel: model)
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

    private static func prepareStore(
        for storage: Storage,
        model: NSManagedObjectModel,
        stepBuilder: MigrationStepBuilder,
        migrator: ProgressiveMigrator
    ) throws -> URL {
        switch storage {
        case .file(let url):
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try migrator.migrateStoreIfNeeded(at: url, to: model) { () throws(MigrationError) in
                try stepBuilder.steps()
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
}
