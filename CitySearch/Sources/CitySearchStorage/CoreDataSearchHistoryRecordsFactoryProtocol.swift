//
//  CoreDataSearchHistoryRecordsFactoryProtocol.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 23/11/2026.
//

import Foundation
import Persistence
import CitySearch

@MainActor
protocol CoreDataSearchHistoryRecordsFactoryProtocol {
    func makeRecords(
        storage: CoreDataStack.Storage
    ) throws -> any SearchHistoryRecordsProtocol
}
