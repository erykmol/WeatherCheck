//
//  TestSchemas.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
@testable import Persistence

enum TestEntity {
    static let item = "Item"
    static let tag = "Tag"

    static func makeTag() -> NSEntityDescription {
        NSEntityDescription(name: tag, properties: [NSAttributeDescription(name: "name", type: .stringAttributeType)])
    }
}

enum TestSchemaV1: VersionedSchema {
    static let versionIdentifier = "1"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "label", type: .stringAttributeType),
                NSAttributeDescription(name: "amount", type: .stringAttributeType),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

enum TestSchemaV2: VersionedSchema {
    static let versionIdentifier = "2"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "label", type: .stringAttributeType),
                NSAttributeDescription(name: "amount", type: .stringAttributeType),
                NSAttributeDescription(name: "note", type: .stringAttributeType, isOptional: true),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

enum TestSchemaV3: VersionedSchema {
    static let versionIdentifier = "3"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "title", type: .stringAttributeType, renamedFrom: "label"),
                NSAttributeDescription(name: "amount", type: .stringAttributeType),
                NSAttributeDescription(name: "note", type: .stringAttributeType, isOptional: true),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

enum TestSchemaV4: VersionedSchema {
    static let versionIdentifier = "4"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "title", type: .stringAttributeType),
                NSAttributeDescription(name: "amount", type: .doubleAttributeType, defaultValue: 0.0),
                NSAttributeDescription(name: "note", type: .stringAttributeType, isOptional: true),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

enum TestSchemaV5: VersionedSchema {
    static let versionIdentifier = "5"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "title", type: .stringAttributeType),
                NSAttributeDescription(name: "amount", type: .doubleAttributeType, defaultValue: 0.0),
                NSAttributeDescription(name: "note", type: .stringAttributeType, isOptional: true),
                NSAttributeDescription(name: "unit", type: .stringAttributeType, defaultValue: "pcs"),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

enum ChangedTestSchema: VersionedSchema {
    static let versionIdentifier = "changed"
    static let versionChecksum = "checksum-before-the-change"

    static func makeEntities() -> [NSEntityDescription] {
        [NSEntityDescription(name: "Changed", properties: [NSAttributeDescription(name: "value", type: .stringAttributeType)])]
    }
}

func unrelatedManagedObjectModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()
    model.entities = [
        NSEntityDescription(name: "Other", properties: [NSAttributeDescription(name: "somethingElse", type: .stringAttributeType)]),
    ]
    return model
}

@objc(BoundTestObject)
final class BoundTestObject: NSManagedObject {}

enum BoundTestSchema: VersionedSchema {
    static let versionIdentifier = "bound"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(
                name: "Bound",
                managedObjectClass: BoundTestObject.self,
                properties: [NSAttributeDescription(name: "name", type: .stringAttributeType)],
                uniquenessConstraints: [["name"]]
            ),
        ]
    }
}

@MainActor
func managedObjectModel(for schema: VersionedSchema.Type) -> NSManagedObjectModel {
    ManagedObjectModels.model(for: schema, bindingClasses: false)
}
