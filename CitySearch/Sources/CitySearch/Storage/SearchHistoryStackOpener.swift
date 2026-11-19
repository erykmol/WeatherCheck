//
//  SearchHistoryStackOpener.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Persistence

@MainActor
struct SearchHistoryStackOpener {
    private let factory: CoreDataStackFactory

    init(factory: CoreDataStackFactory) {
        self.factory = factory
    }

    func openStack(storage: CoreDataStack.Storage) throws -> CoreDataStack {
        do {
            return try factory.makeStack(storage: storage)
        } catch {
            guard case .file(let url) = storage, !isInvalidPlan(error) else { throw error }
            logger.error(
                "Couldn't open the search history, starting a new one: \(String(describing: error), privacy: .public)"
            )
            try factory.deleteStoreFiles(at: url)
            return try factory.makeStack(storage: storage)
        }
    }

    private func isInvalidPlan(_ error: any Error) -> Bool {
        guard case .invalidPlan? = error as? MigrationError else { return false }
        return true
    }
}
