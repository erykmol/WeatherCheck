//
//  FailingMigrationPolicy.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

@objc(FailingMigrationPolicy)
final class FailingMigrationPolicy: NSEntityMigrationPolicy {
    struct Failure: Error {}

    override func createDestinationInstances(
        forSource source: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        throw Failure()
    }
}
