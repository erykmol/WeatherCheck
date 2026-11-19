//
//  MigrationStage.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public enum MigrationStage {
    case lightweight(from: VersionedSchema.Type, to: VersionedSchema.Type)
    case custom(
        from: VersionedSchema.Type,
        to: VersionedSchema.Type,
        policies: [String: NSEntityMigrationPolicy.Type]
    )
}

extension MigrationStage {
    var source: VersionedSchema.Type {
        switch self {
        case .lightweight(let source, _), .custom(let source, _, _):
            source
        }
    }

    var destination: VersionedSchema.Type {
        switch self {
        case .lightweight(_, let destination), .custom(_, let destination, _):
            destination
        }
    }
}
