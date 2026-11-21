//
//  CoreDataStack.Storage+SearchHistory.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Persistence

extension CoreDataStack.Storage {
    public static var searchHistory: CoreDataStack.Storage {
        .applicationSupport(for: SearchHistoryMigrationPlan.self)
    }
}
