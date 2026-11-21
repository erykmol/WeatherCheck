//
//  RelationTestSchemas.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

public enum RelationTestEntity {
    public static let owner = "Owner"
    public static let pet = "Pet"

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

public enum RelationTestSchemaV1: VersionedSchemaProtocol {
    public static let versionIdentifier = "relation-1"
    public static let versionChecksum = "B0DbNyr4/U7/zQ69ySsQx1CHLbSfatd4G5o1cVtWlR0="

    public static func makeEntities() -> [NSEntityDescription] {
        RelationTestEntity.make(petHasNickname: false)
    }
}

public enum RelationTestSchemaV2: VersionedSchemaProtocol {
    public static let versionIdentifier = "relation-2"
    public static let versionChecksum = "yuLf/HDXkvIuu3V3GAvrDp/s4Roczrd0pKmpKrmqHMI="

    public static func makeEntities() -> [NSEntityDescription] {
        RelationTestEntity.make(petHasNickname: true)
    }
}

public enum RelationTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        [RelationTestSchemaV1.self, RelationTestSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [.custom(from: RelationTestSchemaV1.self, to: RelationTestSchemaV2.self, policies: [:])]
    }
}
