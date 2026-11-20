//
//  ManagedObjectModelBuilderProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

protocol ManagedObjectModelBuilderProtocol {
    func model(for schema: any VersionedSchemaProtocol.Type, bindingClasses: Bool) -> NSManagedObjectModel
}
