//
//  ManagedObjectModels.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@MainActor
enum ManagedObjectModels {
    private struct Key: Hashable {
        let schema: ObjectIdentifier
        let bindsClasses: Bool
    }

    private static var cache: [Key: NSManagedObjectModel] = [:]

    static func model(for schema: VersionedSchema.Type, bindingClasses: Bool) -> NSManagedObjectModel {
        let key = Key(schema: ObjectIdentifier(schema), bindsClasses: bindingClasses)
        if let cached = cache[key] {
            return cached
        }
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
        cache[key] = model
        return model
    }

    private static func makeImmutable(_ model: NSManagedObjectModel) {
        _ = NSPersistentStoreCoordinator(managedObjectModel: model)
    }
}
