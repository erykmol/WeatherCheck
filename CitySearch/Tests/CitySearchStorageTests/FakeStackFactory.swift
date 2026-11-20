//
//  FakeStackFactory.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Persistence

@MainActor
final class FakeStackFactory: CoreDataStackFactoryProtocol {
    private var results: [Result<String, MigrationError>]
    private(set) var deletedURLs: [URL] = []

    init(results: [Result<String, MigrationError>]) {
        self.results = results
    }

    func makeStack(storage: CoreDataStack.Storage) throws -> String {
        try results.removeFirst().get()
    }

    func deleteStoreFiles(at url: URL) {
        deletedURLs.append(url)
    }
}
