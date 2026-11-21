//
//  FakeManagedObjectModelBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData
@testable import Persistence
import PersistenceTestFixtures

final class FakeManagedObjectModelBuilder: ManagedObjectModelBuilderProtocol {
    struct Request: Equatable {
        let schema: ObjectIdentifier
        let bindingClasses: Bool
    }

    private(set) var requests: [Request] = []

    func model(for schema: any VersionedSchemaProtocol.Type, bindingClasses: Bool) -> NSManagedObjectModel {
        requests.append(Request(schema: ObjectIdentifier(schema), bindingClasses: bindingClasses))
        return managedObjectModel(for: schema)
    }
}
