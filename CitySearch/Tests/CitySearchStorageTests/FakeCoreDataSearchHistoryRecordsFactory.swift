//
//  FakeCoreDataSearchHistoryRecordsFactory.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import Persistence
import CitySearch
@testable import CitySearchStorage

@MainActor
final class FakeCoreDataSearchHistoryRecordsFactory: CoreDataSearchHistoryRecordsFactoryProtocol {
    enum RequestedStorage: Equatable {
        case file(URL)
        case inMemory
    }

    private var results: [Result<any SearchHistoryRecordsProtocol, any Error>]
    private(set) var requestedStorages: [RequestedStorage] = []

    init(results: [Result<any SearchHistoryRecordsProtocol, any Error>]) {
        self.results = results
    }

    func makeRecords(
        storage: CoreDataStack.Storage
    ) throws -> any SearchHistoryRecordsProtocol {
        switch storage {
        case .file(let url):
            requestedStorages.append(.file(url))
        case .inMemory:
            requestedStorages.append(.inMemory)
        }
        return try results.removeFirst().get()
    }
}
