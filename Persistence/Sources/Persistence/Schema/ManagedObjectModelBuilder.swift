//
//  ManagedObjectModelBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

struct ManagedObjectModelBuilder: ManagedObjectModelBuilderProtocol {
    func makeImmutableModel(
        for schema: any VersionedSchemaProtocol.Type,
        bindingClasses: Bool
    ) -> NSManagedObjectModel {
        let entities = schema.makeEntities()
        if !bindingClasses {
            for entity in entities {
                entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
            }
        }
        let model = NSManagedObjectModel()
        model.entities = entities
        model.versionIdentifiers = [schema.versionIdentifier]
        makeImmutable(model)
        return model
    }

    private func makeImmutable(_ model: NSManagedObjectModel) {
        _ = NSPersistentStoreCoordinator(managedObjectModel: model)
    }
}
