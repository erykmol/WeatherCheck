//
//  ProgressiveMigrator.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

struct ProgressiveMigrator {
    func migrateStoreIfNeeded(
        at storeURL: URL,
        to currentModel: NSManagedObjectModel,
        loadSteps: () throws(MigrationError) -> [MigrationStep]
    ) throws(MigrationError) {
        guard FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false)) else { return }
        let metadata = try storeMetadata(at: storeURL)
        guard !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else { return }

        let steps = try loadSteps()
        let firstStep = steps.firstIndex {
            $0.sourceModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        guard let firstStep else {
            throw .unknownStoreVersion
        }
        for index in firstStep..<steps.count {
            try migrate(storeAt: storeURL, with: steps[index], step: index)
        }

        let migrated = try storeMetadata(at: storeURL)
        guard currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: migrated) else {
            throw .incompleteMigration
        }
    }

    static func temporaryStoreURL(for storeURL: URL) -> URL {
        storeURL
            .deletingLastPathComponent()
            .appending(path: Constants.temporaryStorePrefix + storeURL.lastPathComponent)
    }

    private func migrate(storeAt storeURL: URL, with migrationStep: MigrationStep, step: Int) throws(MigrationError) {
        let temporaryURL = Self.temporaryStoreURL(for: storeURL)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: migrationStep.destinationModel)
        do {
            try autoreleasepool {
                try removeStore(at: temporaryURL, using: coordinator)
                let manager = NSMigrationManager(sourceModel: migrationStep.sourceModel, destinationModel: migrationStep.destinationModel)
                try manager.migrateStore(
                    from: storeURL,
                    type: .sqlite,
                    options: Self.rollbackJournalOptions,
                    mapping: migrationStep.mappingModel,
                    to: temporaryURL,
                    type: .sqlite,
                    options: Self.rollbackJournalOptions
                )
            }
            try coordinator.replacePersistentStore(
                at: storeURL,
                destinationOptions: Self.rollbackJournalOptions,
                withPersistentStoreFrom: temporaryURL,
                sourceOptions: Self.rollbackJournalOptions,
                type: .sqlite
            )
            try removeStore(at: temporaryURL, using: coordinator)
        } catch {
            try? removeStore(at: temporaryURL, using: coordinator)
            throw .stepFailed(step: step, underlying: error)
        }
    }

    private func removeStore(at url: URL, using coordinator: NSPersistentStoreCoordinator) throws {
        let fileManager = FileManager.default
        let path = url.path(percentEncoded: false)
        guard fileManager.fileExists(atPath: path) else { return }
        try coordinator.destroyPersistentStore(at: url, type: .sqlite, options: Self.rollbackJournalOptions)
        for suffix in Constants.storeFileSuffixes where fileManager.fileExists(atPath: path + suffix) {
            try fileManager.removeItem(atPath: path + suffix)
        }
    }

    private func storeMetadata(at url: URL) throws(MigrationError) -> [String: Any] {
        do {
            return try NSPersistentStoreCoordinator.metadataForPersistentStore(type: .sqlite, at: url, options: nil)
        } catch {
            throw .unreadableStore(underlying: error)
        }
    }

    private static var rollbackJournalOptions: [AnyHashable: Any] {
        [NSSQLitePragmasOption: [Constants.journalModeKey: Constants.rollbackJournalMode]]
    }
}

private enum Constants {
    static let temporaryStorePrefix = "migrating_"
    static let storeFileSuffixes = ["", "-wal", "-shm"]
    static let journalModeKey = "journal_mode"
    static let rollbackJournalMode = "DELETE"
}
