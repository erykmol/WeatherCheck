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

        public static func applicationSupport(for plan: any MigrationPlanProtocol.Type) -> Storage {
            .file(.applicationSupportDirectory.appending(path: String(describing: plan) + Constants.storeFileExtension))
        }
    }

    public let viewContext: NSManagedObjectContext
    private let container: NSPersistentContainer

    public convenience init(plan: any MigrationPlanProtocol.Type, storage: Storage) throws {
        let modelBuilder = ManagedObjectModelBuilder()
        try self.init(
            name: String(describing: plan),
            stepBuilder: MigrationStepBuilder(
                plan: plan,
                validator: MigrationPlanValidator(modelBuilder: modelBuilder),
                modelBuilder: modelBuilder,
                mappingModelBuilder: MappingModelBuilder(),
                modelCache: ManagedObjectModelCache.shared
            ),
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
    static let storeFileExtension = ".sqlite"
}
