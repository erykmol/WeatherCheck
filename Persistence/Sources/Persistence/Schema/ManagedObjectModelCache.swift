//
//  ManagedObjectModelCache.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@MainActor
final class ManagedObjectModelCache: ManagedObjectModelCacheProtocol {
    static let shared = ManagedObjectModelCache(modelBuilder: ManagedObjectModelBuilder())

    private let modelBuilder: any ManagedObjectModelBuilderProtocol
    private var models: [ObjectIdentifier: NSManagedObjectModel] = [:]

    init(modelBuilder: any ManagedObjectModelBuilderProtocol) {
        self.modelBuilder = modelBuilder
    }

    func bindModel(for schema: any VersionedSchemaProtocol.Type) -> NSManagedObjectModel {
        let key = ObjectIdentifier(schema)
        if let model = models[key] {
            return model
        }
        let model = modelBuilder.makeImmutableModel(for: schema, bindingClasses: true)
        models[key] = model
        return model
    }
}
