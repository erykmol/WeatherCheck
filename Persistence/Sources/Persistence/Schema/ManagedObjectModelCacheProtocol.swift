//
//  ManagedObjectModelCacheProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

@MainActor
protocol ManagedObjectModelCacheProtocol {
    func bindModel(
        for schema: any VersionedSchemaProtocol.Type
    ) -> NSManagedObjectModel
}
