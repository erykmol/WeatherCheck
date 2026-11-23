//
//  SearchHistoryStackOpener.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import OSLog
import Persistence
import CitySearch

@MainActor
struct SearchHistoryStackOpener<Factory: CoreDataStackFactoryProtocol> {
    private let factory: Factory
    private let deleter: any StoreFilesDeleterProtocol

    init(factory: Factory, deleter: any StoreFilesDeleterProtocol) {
        self.factory = factory
        self.deleter = deleter
    }

    func openStackRecreatingOnFailure(storage: CoreDataStack.Storage) throws -> Factory.Stack {
        do {
            return try factory.makeStack(storage: storage)
        } catch {
            guard case .file(let url) = storage, !isInvalidPlan(error) else { throw error }
            logger.error(
                "Couldn't open the search history, starting a new one: \(String(describing: error), privacy: .public)"
            )
            try deleter.deleteStoreFiles(at: url)
            return try factory.makeStack(storage: storage)
        }
    }

    private func isInvalidPlan(_ error: any Error) -> Bool {
        guard case .invalidPlan? = error as? MigrationError else { return false }
        return true
    }
}
