//
//  FakeManagedObjectModelCache.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData
@testable import Persistence

@MainActor
final class FakeManagedObjectModelCache: ManagedObjectModelCacheProtocol {
    private let model: NSManagedObjectModel
    private(set) var requestedSchemas: [ObjectIdentifier] = []

    init(model: NSManagedObjectModel) {
        self.model = model
    }

    func bindModel(for schema: any VersionedSchemaProtocol.Type) -> NSManagedObjectModel {
        requestedSchemas.append(ObjectIdentifier(schema))
        return model
    }
}
