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
    static let versionChecksum = "cfkzmq0oQ8uTLgESWTYYEN/YwuAshcZ3hcPJLDTTm7w="

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
    static let versionChecksum = "ZGSq/Ow9qY0NzT2JudAZ471nDPch6CxMJsOqLrLUSig="

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
    static let versionChecksum = "STvYgYJf66r+bAJ1jcByWQSyGE5kd9z73vps57KC80Q="

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
    static let versionChecksum = "zGniNm5F03hyqyTfUfpeqDALTN7rCLtENH7JLIGxKmI="

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
    static let versionChecksum = "RXPQQt82E2yLKu5kTwak+TIU0e23SnFh8z2LyViFyLc="

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
    static let versionChecksum = "GvHO5At3IquomIUtjxBm6pxd+r5XwEzNigdcm8fH0Gs="

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

func managedObjectModel(for schema: VersionedSchema.Type) -> NSManagedObjectModel {
    let model = NSManagedObjectModel(schema: schema, bindingClasses: false)
    model.makeImmutable()
    return model
}
