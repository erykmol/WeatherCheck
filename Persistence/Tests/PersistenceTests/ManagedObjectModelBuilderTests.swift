//
//  ManagedObjectModelBuilderTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
@testable import Persistence
import PersistenceTestFixtures

struct ManagedObjectModelBuilderTests {
    @Test func buildsTheEntitiesOfTheSchema() throws {
        let sut = ManagedObjectModelBuilder()

        let model = sut.makeImmutableModel(for: TestSchemaV5.self, bindingClasses: false)

        let item = try #require(model.entitiesByName[TestEntity.item])
        #expect(Set(model.entitiesByName.keys) == [TestEntity.item, TestEntity.tag])
        #expect(Set(item.attributesByName.keys) == ["title", "amount", "note", "unit"])
        #expect(item.attributesByName["amount"]?.attributeType == .doubleAttributeType)
        #expect(item.attributesByName["note"]?.isOptional == true)
        #expect(item.attributesByName["unit"]?.defaultValue as? String == "pcs")
    }

    @Test func keepsTheNameAnAttributeWasRenamedFrom() throws {
        let sut = ManagedObjectModelBuilder()

        let model = sut.makeImmutableModel(for: TestSchemaV3.self, bindingClasses: false)

        let item = try #require(model.entitiesByName[TestEntity.item])
        #expect(item.attributesByName["title"]?.renamingIdentifier == "label")
    }

    @Test func addsTheUniquenessConstraint() throws {
        let sut = ManagedObjectModelBuilder()

        let model = sut.makeImmutableModel(for: BoundTestSchema.self, bindingClasses: false)

        let entity = try #require(model.entitiesByName["Bound"])
        #expect(entity.uniquenessConstraints as? [[String]] == [["name"]])
    }

    @Test func bindsEntityClassesOnlyWhenAsked() {
        let sut = ManagedObjectModelBuilder()

        let bound = sut.makeImmutableModel(for: BoundTestSchema.self, bindingClasses: true)
        let unbound = sut.makeImmutableModel(for: BoundTestSchema.self, bindingClasses: false)

        #expect(bound.entitiesByName["Bound"]?.managedObjectClassName == NSStringFromClass(BoundTestObject.self))
        #expect(unbound.entitiesByName["Bound"]?.managedObjectClassName == NSStringFromClass(NSManagedObject.self))
    }

    @Test func entityClassesDoNotChangeTheVersionHashes() {
        let sut = ManagedObjectModelBuilder()

        let bound = sut.makeImmutableModel(for: BoundTestSchema.self, bindingClasses: true)
        let unbound = sut.makeImmutableModel(for: BoundTestSchema.self, bindingClasses: false)

        #expect(bound.entityVersionHashesByName == unbound.entityVersionHashesByName)
    }
}
