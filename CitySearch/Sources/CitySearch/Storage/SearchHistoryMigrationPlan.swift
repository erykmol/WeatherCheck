//
//  SearchHistoryMigrationPlan.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Persistence

enum SearchHistoryMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SearchHistorySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
