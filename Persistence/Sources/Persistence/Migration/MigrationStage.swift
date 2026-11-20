//
//  MigrationStage.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public enum MigrationStage {
    case lightweight(from: any VersionedSchemaProtocol.Type, to: any VersionedSchemaProtocol.Type)
    case custom(
        from: any VersionedSchemaProtocol.Type,
        to: any VersionedSchemaProtocol.Type,
        policies: [String: NSEntityMigrationPolicy.Type]
    )
}

extension MigrationStage {
    var source: any VersionedSchemaProtocol.Type {
        switch self {
        case .lightweight(let source, _), .custom(let source, _, _):
            source
        }
    }

    var destination: any VersionedSchemaProtocol.Type {
        switch self {
        case .lightweight(_, let destination), .custom(_, let destination, _):
            destination
        }
    }
}
