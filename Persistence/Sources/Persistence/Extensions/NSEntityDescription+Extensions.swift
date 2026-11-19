//
//  NSEntityDescription+Extensions.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public extension NSEntityDescription {
    convenience init(
        name: String,
        managedObjectClass: NSManagedObject.Type = NSManagedObject.self,
        properties: [NSPropertyDescription],
        uniquenessConstraints: [[String]] = []
    ) {
        self.init()
        self.name = name
        managedObjectClassName = NSStringFromClass(managedObjectClass)
        self.properties = properties
        self.uniquenessConstraints = uniquenessConstraints
    }
}
