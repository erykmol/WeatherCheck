//
//  ManagedObjectModelCache.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@MainActor
final class ManagedObjectModelCache {
    static let shared = ManagedObjectModelCache()

    private var models: [ObjectIdentifier: NSManagedObjectModel] = [:]

    func bindModel(for schema: any VersionedSchema.Type) -> NSManagedObjectModel {
        let key = ObjectIdentifier(schema)
        if let model = models[key] {
            return model
        }
        let model = NSManagedObjectModel(schema: schema, bindingClasses: true)
        model.makeImmutable()
        models[key] = model
        return model
    }
}
