//
//  RelationTestSchemas.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

enum RelationTestEntity {
    static let owner = "Owner"
    static let pet = "Pet"

    static func make(petHasNickname: Bool) -> [NSEntityDescription] {
        let owner = NSEntityDescription(name: Self.owner, properties: [NSAttributeDescription(name: "name", type: .stringAttributeType)])
        var petProperties: [NSPropertyDescription] = [NSAttributeDescription(name: "name", type: .stringAttributeType)]
        if petHasNickname {
            petProperties.append(NSAttributeDescription(name: "nickname", type: .stringAttributeType, isOptional: true))
        }
        let pet = NSEntityDescription(name: Self.pet, properties: petProperties)

        let pets = NSRelationshipDescription()
        pets.name = "pets"
        pets.destinationEntity = pet
        pets.minCount = 0
        pets.maxCount = 0
        pets.deleteRule = .cascadeDeleteRule

        let petOwner = NSRelationshipDescription()
        petOwner.name = "owner"
        petOwner.destinationEntity = owner
        petOwner.minCount = 0
        petOwner.maxCount = 1
        petOwner.deleteRule = .nullifyDeleteRule

        pets.inverseRelationship = petOwner
        petOwner.inverseRelationship = pets
        owner.properties.append(pets)
        pet.properties.append(petOwner)
        return [owner, pet]
    }
}

enum RelationTestSchemaV1: VersionedSchema {
    static let versionIdentifier = "relation-1"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        RelationTestEntity.make(petHasNickname: false)
    }
}

enum RelationTestSchemaV2: VersionedSchema {
    static let versionIdentifier = "relation-2"
    static let versionChecksum = ""

    static func makeEntities() -> [NSEntityDescription] {
        RelationTestEntity.make(petHasNickname: true)
    }
}

enum RelationTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [RelationTestSchemaV1.self, RelationTestSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [.custom(from: RelationTestSchemaV1.self, to: RelationTestSchemaV2.self, policies: [:])]
    }
}
