//
//  MigrationPlanProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public protocol MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] { get }
    static var stages: [MigrationStage] { get }
}
