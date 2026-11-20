//
//  CoreDataStackFactory.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

@MainActor
public struct CoreDataStackFactory: CoreDataStackFactoryProtocol {
    private let plan: MigrationPlan.Type

    public init(plan: MigrationPlan.Type) {
        self.plan = plan
    }

    public func makeStack(storage: CoreDataStack.Storage) throws -> CoreDataStack {
        try CoreDataStack(plan: plan, storage: storage)
    }

    public func deleteStoreFiles(at url: URL) throws {
        for suffix in Constants.storeFileSuffixes {
            let file = URL(filePath: url.path(percentEncoded: false) + suffix)
            if FileManager.default.fileExists(atPath: file.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: file)
            }
        }
    }
}

private enum Constants {
    static let storeFileSuffixes = ["", "-wal", "-shm"]
}
