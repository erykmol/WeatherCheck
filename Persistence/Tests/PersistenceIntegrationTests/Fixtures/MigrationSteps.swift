//
//  MigrationSteps.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
@testable import Persistence

@MainActor
func migrationSteps(for plan: any MigrationPlanProtocol.Type) throws -> [MigrationStep] {
    let modelBuilder = ManagedObjectModelBuilder()
    return try MigrationStepBuilder(
        plan: plan,
        validator: MigrationPlanValidator(modelBuilder: modelBuilder),
        modelBuilder: modelBuilder,
        mappingModelBuilder: MappingModelBuilder(),
        modelCache: ManagedObjectModelCache(modelBuilder: modelBuilder)
    ).steps()
}
