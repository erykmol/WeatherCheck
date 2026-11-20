//
//  MigrationStage.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public enum MigrationStage {
    case lightweight(from: VersionedSchemaProtocol.Type, to: VersionedSchemaProtocol.Type)
    case custom(
        from: VersionedSchemaProtocol.Type,
        to: VersionedSchemaProtocol.Type,
        policies: [String: NSEntityMigrationPolicy.Type]
    )
}

extension MigrationStage {
    var source: VersionedSchemaProtocol.Type {
        switch self {
        case .lightweight(let source, _), .custom(let source, _, _):
            source
        }
    }

    var destination: VersionedSchemaProtocol.Type {
        switch self {
        case .lightweight(_, let destination), .custom(_, let destination, _):
            destination
        }
    }
}
