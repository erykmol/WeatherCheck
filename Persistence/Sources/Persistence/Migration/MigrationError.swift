//
//  MigrationError.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public enum MigrationError: Error {
    case invalidPlan(reason: String)
    case noInferredMapping(from: String, to: String, underlying: any Error)
    case unreadableStore(underlying: any Error)
    case unknownStoreVersion
    case stepFailed(step: Int, underlying: any Error)
    case incompleteMigration
}
