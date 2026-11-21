//
//  MigrationStepBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@MainActor
struct MigrationStepBuilder {
    private let plan: any MigrationPlanProtocol.Type
    private let currentSchema: any VersionedSchemaProtocol.Type
    private let modelBuilder: any ManagedObjectModelBuilderProtocol
    private let mappingModelBuilder: any MappingModelBuilderProtocol
    private let modelCache: any ManagedObjectModelCacheProtocol

    var currentModel: NSManagedObjectModel {
        modelCache.bindModel(for: currentSchema)
    }

    init(
        plan: any MigrationPlanProtocol.Type,
        validator: any MigrationPlanValidatorProtocol,
        modelBuilder: any ManagedObjectModelBuilderProtocol,
        mappingModelBuilder: any MappingModelBuilderProtocol,
        modelCache: any ManagedObjectModelCacheProtocol
    ) throws(MigrationError) {
        guard let currentSchema = plan.schemas.last else {
            throw .invalidPlan(reason: "The plan has no schemas")
        }
        try validator.validate(plan)
        self.plan = plan
        self.currentSchema = currentSchema
        self.modelBuilder = modelBuilder
        self.mappingModelBuilder = mappingModelBuilder
        self.modelCache = modelCache
    }

    func steps() throws(MigrationError) -> [MigrationStep] {
        var steps: [MigrationStep] = []
        for stage in plan.stages {
            let source = modelBuilder.model(for: stage.source, bindingClasses: false)
            let destination = modelBuilder.model(for: stage.destination, bindingClasses: false)
            let mapping = try mappingModelBuilder.mappingModel(for: stage, from: source, to: destination)
            steps.append(MigrationStep(sourceModel: source, destinationModel: destination, mappingModel: mapping))
        }
        return steps
    }
}
