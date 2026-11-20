//
//  SearchHistoryMigrationPlan.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Persistence

enum SearchHistoryMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [SearchHistorySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
