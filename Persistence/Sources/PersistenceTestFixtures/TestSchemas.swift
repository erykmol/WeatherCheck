//
//  TestSchemas.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

public enum TestEntity {
    public static let item = "Item"
    public static let tag = "Tag"

    static func makeTag() -> NSEntityDescription {
        NSEntityDescription(name: tag, properties: [NSAttributeDescription(name: "name", type: .stringAttributeType)])
    }
}

public enum TestSchemaV1: VersionedSchemaProtocol {
    public static let versionIdentifier = "1"
    public static let versionChecksum = "cfkzmq0oQ8uTLgESWTYYEN/YwuAshcZ3hcPJLDTTm7w="

    public static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(name: TestEntity.item, properties: [
                NSAttributeDescription(name: "label", type: .stringAttributeType),
                NSAttributeDescription(name: "amount", type: .stringAttributeType),
            ]),
            TestEntity.makeTag(),
        ]
    }
}

public enum TestSchemaV2: VersionedSchemaProtocol {
    public static let versionIdentifier = "2"
    public static let versionChecksum = "ZGSq/Ow9qY0NzT2JudAZ471nDPch6CxMJsOqLrLUSig="

    public static func makeEntities() -> [NSEntityDescription] {
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

public enum TestSchemaV3: VersionedSchemaProtocol {
    public static let versionIdentifier = "3"
    public static let versionChecksum = "STvYgYJf66r+bAJ1jcByWQSyGE5kd9z73vps57KC80Q="

    public static func makeEntities() -> [NSEntityDescription] {
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

public enum TestSchemaV4: VersionedSchemaProtocol {
    public static let versionIdentifier = "4"
    public static let versionChecksum = "zGniNm5F03hyqyTfUfpeqDALTN7rCLtENH7JLIGxKmI="

    public static func makeEntities() -> [NSEntityDescription] {
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

public enum TestSchemaV5: VersionedSchemaProtocol {
    public static let versionIdentifier = "5"
    public static let versionChecksum = "RXPQQt82E2yLKu5kTwak+TIU0e23SnFh8z2LyViFyLc="

    public static func makeEntities() -> [NSEntityDescription] {
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

public enum ChangedTestSchema: VersionedSchemaProtocol {
    public static let versionIdentifier = "changed"
    public static let versionChecksum = "checksum-before-the-change"

    public static func makeEntities() -> [NSEntityDescription] {
        [NSEntityDescription(name: "Changed", properties: [NSAttributeDescription(name: "value", type: .stringAttributeType)])]
    }
}

public func makeUnrelatedManagedObjectModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()
    model.entities = [
        NSEntityDescription(name: "Other", properties: [NSAttributeDescription(name: "somethingElse", type: .stringAttributeType)]),
    ]
    return model
}

@objc(BoundTestObject)
public final class BoundTestObject: NSManagedObject {}

public enum BoundTestSchema: VersionedSchemaProtocol {
    public static let versionIdentifier = "bound"
    public static let versionChecksum = "GvHO5At3IquomIUtjxBm6pxd+r5XwEzNigdcm8fH0Gs="

    public static func makeEntities() -> [NSEntityDescription] {
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

public func makeManagedObjectModel(
    for schema: any VersionedSchemaProtocol.Type
) -> NSManagedObjectModel {
    let entities = schema.makeEntities()
    for entity in entities {
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
    }
    let model = NSManagedObjectModel()
    model.entities = entities
    model.versionIdentifiers = [schema.versionIdentifier]
    _ = NSPersistentStoreCoordinator(managedObjectModel: model)
    return model
}
