//
//  NSAttributeDescription+Extensions.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public extension NSAttributeDescription {
    convenience init(
        name: String,
        type: NSAttributeType,
        isOptional: Bool = false,
        defaultValue: Any? = nil,
        renamedFrom: String? = nil
    ) {
        self.init()
        self.name = name
        attributeType = type
        self.isOptional = isOptional
        self.defaultValue = defaultValue
        renamingIdentifier = renamedFrom
    }
}
