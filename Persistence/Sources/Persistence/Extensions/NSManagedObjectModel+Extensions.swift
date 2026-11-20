//
//  NSManagedObjectModel+Extensions.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    convenience init(schema: any VersionedSchemaProtocol.Type, bindingClasses: Bool) {
        self.init()
        let entities = schema.makeEntities()
        if !bindingClasses {
            for entity in entities {
                entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
            }
        }
        self.entities = entities
        versionIdentifiers = [schema.versionIdentifier]
    }

    func makeImmutable() {
        _ = NSPersistentStoreCoordinator(managedObjectModel: self)
    }
}
