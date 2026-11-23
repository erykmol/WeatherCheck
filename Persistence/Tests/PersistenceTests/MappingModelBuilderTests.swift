//
//  MappingModelBuilderTests.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
import CoreData
@testable import Persistence
import PersistenceTestFixtures

struct MappingModelBuilderTests {
    @Test func infersTheMappingOfALightweightStage() throws {
        let sut = MappingModelBuilder()

        let mapping = try sut.makeMappingModel(
            for: .lightweight(from: TestSchemaV1.self, to: TestSchemaV2.self),
            from: makeManagedObjectModel(for: TestSchemaV1.self),
            to: makeManagedObjectModel(for: TestSchemaV2.self)
        )

        #expect(Set(mapping.entityMappings.compactMap(\.destinationEntityName)) == [TestEntity.item, TestEntity.tag])
    }

    @Test func usesTheEntitysPolicyInACustomStage() throws {
        let sut = MappingModelBuilder()

        let mapping = try sut.makeMappingModel(
            for: .custom(from: TestSchemaV3.self, to: TestSchemaV4.self, policies: [TestEntity.item: AmountToNumberPolicy.self]),
            from: makeManagedObjectModel(for: TestSchemaV3.self),
            to: makeManagedObjectModel(for: TestSchemaV4.self)
        )

        let item = try #require(findEntityMapping(named: TestEntity.item, in: mapping))
        #expect(item.entityMigrationPolicyClassName == NSStringFromClass(AmountToNumberPolicy.self))
        #expect((item.attributeMappings ?? []).isEmpty)
    }

    @Test func copiesTheAttributesOfEntitiesWithoutAPolicy() throws {
        let sut = MappingModelBuilder()

        let mapping = try sut.makeMappingModel(
            for: .custom(from: TestSchemaV3.self, to: TestSchemaV4.self, policies: [TestEntity.item: AmountToNumberPolicy.self]),
            from: makeManagedObjectModel(for: TestSchemaV3.self),
            to: makeManagedObjectModel(for: TestSchemaV4.self)
        )

        let tag = try #require(findEntityMapping(named: TestEntity.tag, in: mapping))
        #expect(tag.entityMigrationPolicyClassName == nil)
        #expect(tag.attributeMappings?.map(\.name) == ["name"])
    }

    @Test func readsARenamedAttributeFromItsOldName() throws {
        let sut = MappingModelBuilder()

        let mapping = try sut.makeMappingModel(
            for: .custom(from: TestSchemaV2.self, to: TestSchemaV3.self, policies: [:]),
            from: makeManagedObjectModel(for: TestSchemaV2.self),
            to: makeManagedObjectModel(for: TestSchemaV3.self)
        )

        let item = try #require(findEntityMapping(named: TestEntity.item, in: mapping))
        let title = item.attributeMappings?.first { $0.name == "title" }
        #expect(title?.valueExpression?.description.contains("label") == true)
    }

    @Test func mapsRelationshipsToTheInstancesMigratedFromTheirTarget() throws {
        let sut = MappingModelBuilder()

        let mapping = try sut.makeMappingModel(
            for: .custom(from: RelationTestSchemaV1.self, to: RelationTestSchemaV2.self, policies: [:]),
            from: makeManagedObjectModel(for: RelationTestSchemaV1.self),
            to: makeManagedObjectModel(for: RelationTestSchemaV2.self)
        )

        let pet = try #require(findEntityMapping(named: RelationTestEntity.pet, in: mapping))
        let owner = pet.relationshipMappings?.first { $0.name == "owner" }
        #expect(owner?.valueExpression?.description.contains("OwnerToOwner") == true)
    }

    private func findEntityMapping(
        named name: String,
        in mapping: NSMappingModel
    ) -> NSEntityMapping? {
        mapping.entityMappings.first { $0.destinationEntityName == name }
    }
}
