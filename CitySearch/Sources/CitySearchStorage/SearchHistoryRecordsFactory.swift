//
//  SearchHistoryRecordsFactory.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import OSLog
import Persistence
import CitySearch

@MainActor
public struct SearchHistoryRecordsFactory {
    private let coreDataFactory: any CoreDataSearchHistoryRecordsFactoryProtocol
    private let unsavedRecords: any SearchHistoryRecordsProtocol

    public init() {
        self.init(coreDataFactory: CoreDataSearchHistoryRecordsFactory(), unsavedRecords: UnsavedSearchHistoryRecords())
    }

    init(
        coreDataFactory: any CoreDataSearchHistoryRecordsFactoryProtocol,
        unsavedRecords: any SearchHistoryRecordsProtocol
    ) {
        self.coreDataFactory = coreDataFactory
        self.unsavedRecords = unsavedRecords
    }

    public func makeRecordsWithMemoryAndUnsavedFallbacks(
        storage: CoreDataStack.Storage
    ) -> any SearchHistoryRecordsProtocol {
        do {
            return try coreDataFactory.makeRecords(storage: storage)
        } catch {
            logger.error("Couldn't open the search history, it won't be kept: \(String(describing: error), privacy: .public)")
        }
        do {
            return try coreDataFactory.makeRecords(storage: .inMemory)
        } catch {
            logger.error("Couldn't open an in-memory search history either, searches won't be remembered: \(String(describing: error), privacy: .public)")
        }
        return unsavedRecords
    }
}
