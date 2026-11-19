//
//  MigrationPlan.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public protocol MigrationPlan {
    static var schemas: [any VersionedSchema.Type] { get }
    static var stages: [MigrationStage] { get }
}
