//
//  MigrationError.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public enum MigrationError: Error {
    case invalidPlan(reason: String)
    case noInferredMapping(from: String, to: String, underlying: Error)
    case unreadableStore(underlying: Error)
    case unknownStoreVersion
    case stepFailed(step: Int, underlying: Error)
    case incompleteMigration
}
