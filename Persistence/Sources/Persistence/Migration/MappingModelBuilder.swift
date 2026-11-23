//
//  MappingModelBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

struct MappingModelBuilder: MappingModelBuilderProtocol {
    func mappingModel(
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

    private func customMappingModel(
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

    private func attributeMappings(
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

    private func relationshipMappings(
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

    private func mappingName(forEntityNamed name: String) -> String {
        "\(name)To\(name)"
    }

    private func sourceExpression(forEntityNamed name: String) -> NSExpression {
        NSFetchRequestExpression.expression(
            forFetch: NSExpression(forConstantValue: NSFetchRequest<NSManagedObject>(entityName: name)),
            context: call(#selector(getter: NSMigrationManager.sourceContext), on: Constants.managerVariable),
            countOnly: false
        )
    }

    private func sourceValue(forKey key: String) -> NSExpression {
        call(#selector(NSObject.value(forKey:)), on: Constants.sourceVariable, with: [NSExpression(forConstantValue: key)])
    }

    private func destinationInstances(
        ofMapping mappingName: String,
        for sourceInstances: NSExpression
    ) -> NSExpression {
        call(
            #selector(NSMigrationManager.destinationInstances(forEntityMappingName:sourceInstances:)),
            on: Constants.managerVariable,
            with: [NSExpression(forConstantValue: mappingName), sourceInstances]
        )
    }

    private func call(
        _ selector: Selector,
        on variable: String,
        with arguments: [NSExpression] = []
    ) -> NSExpression {
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
