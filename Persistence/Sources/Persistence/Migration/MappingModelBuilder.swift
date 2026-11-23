//
//  MappingModelBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

struct MappingModelBuilder: MappingModelBuilderProtocol {
    func makeMappingModel(
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
            return makeCustomMappingModel(from: source, to: destination, policies: policies)
        }
    }

    private func makeCustomMappingModel(
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
            entityMapping.name = makeMappingName(forEntityNamed: name)
            entityMapping.mappingType = .transformEntityMappingType
            entityMapping.sourceEntityName = name
            entityMapping.sourceEntityVersionHash = sourceEntity.versionHash
            entityMapping.destinationEntityName = name
            entityMapping.destinationEntityVersionHash = destinationEntity.versionHash
            entityMapping.sourceExpression = makeSourceExpression(forEntityNamed: name)
            if let policy = policies[name] {
                entityMapping.entityMigrationPolicyClassName = NSStringFromClass(policy)
            } else {
                entityMapping.attributeMappings = makeAttributeMappings(from: sourceEntity, to: destinationEntity)
                entityMapping.relationshipMappings = makeRelationshipMappings(
                    from: sourceEntity,
                    to: destinationEntity,
                    in: source
                )
            }
            return entityMapping
        }
        return mapping
    }

    private func makeAttributeMappings(
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
            mapping.valueExpression = makeSourceValueExpression(forKey: sourceName)
            return mapping
        }
    }

    private func makeRelationshipMappings(
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
            mapping.valueExpression = makeDestinationInstancesExpression(
                ofMapping: makeMappingName(forEntityNamed: target),
                for: makeSourceValueExpression(forKey: sourceName)
            )
            return mapping
        }
    }

    private func makeMappingName(forEntityNamed name: String) -> String {
        "\(name)To\(name)"
    }

    private func makeSourceExpression(
        forEntityNamed name: String
    ) -> NSExpression {
        NSFetchRequestExpression.expression(
            forFetch: NSExpression(forConstantValue: NSFetchRequest<NSManagedObject>(entityName: name)),
            context: makeCallExpression(#selector(getter: NSMigrationManager.sourceContext), on: Constants.managerVariable),
            countOnly: false
        )
    }

    private func makeSourceValueExpression(forKey key: String) -> NSExpression {
        makeCallExpression(#selector(NSObject.value(forKey:)), on: Constants.sourceVariable, with: [NSExpression(forConstantValue: key)])
    }

    private func makeDestinationInstancesExpression(
        ofMapping mappingName: String,
        for sourceInstances: NSExpression
    ) -> NSExpression {
        makeCallExpression(
            #selector(NSMigrationManager.destinationInstances(forEntityMappingName:sourceInstances:)),
            on: Constants.managerVariable,
            with: [NSExpression(forConstantValue: mappingName), sourceInstances]
        )
    }

    private func makeCallExpression(
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
