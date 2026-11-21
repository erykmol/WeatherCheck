//
//  AmountToNumberPolicy.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public final class AmountToNumberPolicy: NSEntityMigrationPolicy {
    public override func createDestinationInstances(
        forSource source: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        guard let entityName = mapping.destinationEntityName else { return }
        let destination = NSEntityDescription.insertNewObject(forEntityName: entityName, into: manager.destinationContext)
        destination.setValue(source.value(forKey: "title"), forKey: "title")
        destination.setValue(source.value(forKey: "note"), forKey: "note")
        let amount = (source.value(forKey: "amount") as? String).flatMap { Double($0) }
        destination.setValue(amount ?? 0, forKey: "amount")
        manager.associate(sourceInstance: source, withDestinationInstance: destination, for: mapping)
    }
}
