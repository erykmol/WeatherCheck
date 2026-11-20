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
    private let modelCache: ManagedObjectModelCache

    var currentModel: NSManagedObjectModel {
        modelCache.bindModel(for: currentSchema)
    }

    init(plan: any MigrationPlanProtocol.Type, modelCache: ManagedObjectModelCache) throws(MigrationError) {
        guard let currentSchema = plan.schemas.last else {
            throw .invalidPlan(reason: "The plan has no schemas")
        }
        try Self.validate(plan)
        self.plan = plan
        self.currentSchema = currentSchema
        self.modelCache = modelCache
    }

    func steps() throws(MigrationError) -> [MigrationStep] {
        var steps: [MigrationStep] = []
        for stage in plan.stages {
            let source = Self.unboundModel(for: stage.source)
            let destination = Self.unboundModel(for: stage.destination)
            let mapping = try Self.mappingModel(for: stage, from: source, to: destination)
            steps.append(MigrationStep(sourceModel: source, destinationModel: destination, mappingModel: mapping))
        }
        return steps
    }

    private static func validate(_ plan: any MigrationPlanProtocol.Type) throws(MigrationError) {
        let schemas = plan.schemas
        let stages = plan.stages
        guard stages.count == schemas.count - 1 else {
            throw .invalidPlan(
                reason: "\(schemas.count) schemas need \(schemas.count - 1) stages, found \(stages.count)"
            )
        }
        for (index, stage) in stages.enumerated() {
            guard
                ObjectIdentifier(stage.source) == ObjectIdentifier(schemas[index]),
                ObjectIdentifier(stage.destination) == ObjectIdentifier(schemas[index + 1])
            else {
                throw .invalidPlan(
                    reason: "Stage \(index) doesn't go from schema \(index) to schema \(index + 1)"
                )
            }
        }
        try validateChecksums(of: schemas)
    }

    private static func validateChecksums(of schemas: [any VersionedSchemaProtocol.Type]) throws(MigrationError) {
        let changes = schemas.compactMap { (schema: any VersionedSchemaProtocol.Type) -> String? in
            let checksum = unboundModel(for: schema).versionChecksum
            guard checksum != schema.versionChecksum else {
                return nil
            }
            return #"\#(schema) has checksum "\#(checksum)" but declares "\#(schema.versionChecksum)""#
        }
        guard changes.isEmpty else {
            throw .invalidPlan(
                reason: "A versioned schema changed, add a new version instead: \(changes.joined(separator: "; "))"
            )
        }
    }

    private static func unboundModel(for schema: any VersionedSchemaProtocol.Type) -> NSManagedObjectModel {
        let model = NSManagedObjectModel(schema: schema, bindingClasses: false)
        model.makeImmutable()
        return model
    }

    private static func mappingModel(
        for stage: MigrationStage,
        from source: NSManagedObjectModel,
        to destination: NSManagedObjectModel
    ) throws(MigrationError) -> NSMappingModel {
        switch stage {
        case .lightweight:
            do {
                return try NSMappingModel.inferredMappingModel(forSourceModel: source, destinationModel: destination)
            } catch {
                throw .noInferredMapping(
                    from: stage.source.versionIdentifier,
                    to: stage.destination.versionIdentifier,
                    underlying: error
                )
            }
        case .custom(_, _, let policies):
            return customMappingModel(from: source, to: destination, policies: policies)
        }
    }

    private static func customMappingModel(
        from source: NSManagedObjectModel,
        to destination: NSManagedObjectModel,
        policies: [String: NSEntityMigrationPolicy.Type]
    ) -> NSMappingModel {
        let mapping = NSMappingModel()
        mapping.entityMappings = destination.entities.compactMap { (destinationEntity: NSEntityDescription) -> NSEntityMapping? in
            guard
                let name = destinationEntity.name,
                let sourceEntity = source.entitiesByName[name]
            else {
                return nil
            }
            let entityMapping = NSEntityMapping()
            entityMapping.name = mappingName(forEntityNamed: name)
            entityMapping.mappingType = .transformEntityMappingType
            entityMapping.sourceEntityName = name
            entityMapping.sourceEntityVersionHash = sourceEntity.versionHash
            entityMapping.destinationEntityName = name
            entityMapping.destinationEntityVersionHash = destinationEntity.versionHash
            entityMapping.sourceExpression = sourceExpression(forEntityNamed: name)
            if let policy = policies[name] {
                entityMapping.entityMigrationPolicyClassName = NSStringFromClass(policy)
            } else {
                entityMapping.attributeMappings = attributeMappings(from: sourceEntity, to: destinationEntity)
                entityMapping.relationshipMappings = relationshipMappings(
                    from: sourceEntity,
                    to: destinationEntity,
                    in: source
                )
            }
            return entityMapping
        }
        return mapping
    }

    private static func attributeMappings(
        from source: NSEntityDescription,
        to destination: NSEntityDescription
    ) -> [NSPropertyMapping] {
        destination.attributesByName.keys.sorted().compactMap { (name: String) -> NSPropertyMapping? in
            let sourceName = if source.attributesByName[name] == nil {
                destination.attributesByName[name]?.renamingIdentifier
            } else {
                name
            }
            guard let sourceName, source.attributesByName[sourceName] != nil else {
                return nil
            }
            let mapping = NSPropertyMapping()
            mapping.name = name
            mapping.valueExpression = sourceValue(forKey: sourceName)
            return mapping
        }
    }

    private static func relationshipMappings(
        from source: NSEntityDescription,
        to destination: NSEntityDescription,
        in sourceModel: NSManagedObjectModel
    ) -> [NSPropertyMapping] {
        destination.relationshipsByName.keys.sorted().compactMap { (name: String) -> NSPropertyMapping? in
            let sourceName = source.relationshipsByName[name] == nil
                ? destination.relationshipsByName[name]?.renamingIdentifier
                : name
            guard
                let sourceName,
                source.relationshipsByName[sourceName] != nil,
                let target = destination.relationshipsByName[name]?.destinationEntity?.name,
                sourceModel.entitiesByName[target] != nil
            else {
                return nil
            }
            let mapping = NSPropertyMapping()
            mapping.name = name
            mapping.valueExpression = destinationInstances(
                ofMapping: mappingName(forEntityNamed: target),
                for: sourceValue(forKey: sourceName)
            )
            return mapping
        }
    }

    private static func mappingName(forEntityNamed name: String) -> String {
        "\(name)To\(name)"
    }

    private static func sourceExpression(forEntityNamed name: String) -> NSExpression {
        NSFetchRequestExpression.expression(
            forFetch: NSExpression(forConstantValue: NSFetchRequest<NSManagedObject>(entityName: name)),
            context: call(#selector(getter: NSMigrationManager.sourceContext), on: Constants.managerVariable),
            countOnly: false
        )
    }

    private static func sourceValue(forKey key: String) -> NSExpression {
        call(#selector(NSObject.value(forKey:)), on: Constants.sourceVariable, with: [NSExpression(forConstantValue: key)])
    }

    private static func destinationInstances(ofMapping mappingName: String, for sourceInstances: NSExpression) -> NSExpression {
        call(
            #selector(NSMigrationManager.destinationInstances(forEntityMappingName:sourceInstances:)),
            on: Constants.managerVariable,
            with: [NSExpression(forConstantValue: mappingName), sourceInstances]
        )
    }

    private static func call(_ selector: Selector, on variable: String, with arguments: [NSExpression] = []) -> NSExpression {
        NSExpression(
            forFunction: NSExpression(forVariable: variable),
            selectorName: NSStringFromSelector(selector),
            arguments: arguments
        )
    }
}

private enum Constants {
    static let managerVariable = "manager"
    static let sourceVariable = "source"
}
