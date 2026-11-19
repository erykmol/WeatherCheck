//
//  MigrationStepBuilderTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
@testable import Persistence

@MainActor
struct MigrationStepBuilderTests {
    @Test func buildsAStepBetweenEveryPairOfSchemas() throws {
        let sut = try MigrationStepBuilder(plan: TestMigrationPlan.self, modelCache: ManagedObjectModelCache())

        let steps = try sut.steps()

        let hashes = TestPlanParts.schemas.map { managedObjectModel(for: $0).entityVersionHashesByName }
        #expect(steps.map(\.sourceModel.entityVersionHashesByName) == Array(hashes.dropLast()))
        #expect(steps.map(\.destinationModel.entityVersionHashesByName) == Array(hashes.dropFirst()))
    }

    @Test func copiesEntitiesWithoutAPolicyInACustomStage() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let source = managedObjectModel(for: TestSchemaV3.self)
        let store = try TestStore()
        try store.seed(source, with: [["title": "Apples", "amount": "2.5"]])
        try store.seed(source, entity: TestEntity.tag, with: [["name": "Fruit"]])
        let sut = try MigrationStepBuilder(plan: TestMigrationPlan.self, modelCache: ManagedObjectModelCache())

        let steps = try sut.steps()

        try ProgressiveMigrator().migrateStoreIfNeeded(at: store.url, to: current) { steps }
        #expect(try store.tagNames(current) == ["Fruit"])
    }

    @Test func copiesRelationshipsInACustomStage() throws {
        let current = managedObjectModel(for: RelationTestSchemaV2.self)
        let store = try TestStore()
        try store.seedOwner(named: "Ala", withPetNamed: "Burek", in: managedObjectModel(for: RelationTestSchemaV1.self))
        let sut = try MigrationStepBuilder(plan: RelationTestMigrationPlan.self, modelCache: ManagedObjectModelCache())

        let steps = try sut.steps()

        try ProgressiveMigrator().migrateStoreIfNeeded(at: store.url, to: current) { steps }
        #expect(try store.petOwnerNames(current) == ["Ala"])
    }

    @Test func takesTheCurrentModelFromTheCache() throws {
        let cache = ManagedObjectModelCache()
        let sut = try MigrationStepBuilder(plan: BoundTestMigrationPlan.self, modelCache: cache)

        let model = sut.currentModel

        #expect(model === cache.bindModel(for: BoundTestSchema.self))
    }

    @Test func rejectsAPlanWithoutSchemas() {
        let error = #expect(throws: MigrationError.self) {
            _ = try MigrationStepBuilder(plan: EmptyTestMigrationPlan.self, modelCache: ManagedObjectModelCache())
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsAPlanWithAMissingStage() {
        let error = #expect(throws: MigrationError.self) {
            _ = try MigrationStepBuilder(plan: MissingStageTestMigrationPlan.self, modelCache: ManagedObjectModelCache())
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsStagesThatDoNotFollowTheSchemaOrder() {
        let error = #expect(throws: MigrationError.self) {
            _ = try MigrationStepBuilder(plan: MisorderedTestMigrationPlan.self, modelCache: ManagedObjectModelCache())
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsAChangedSchemaAndNamesItsActualChecksum() {
        let error = #expect(throws: MigrationError.self) {
            _ = try MigrationStepBuilder(plan: ChangedSchemaTestMigrationPlan.self, modelCache: ManagedObjectModelCache())
        }

        let reason: String? = switch error {
        case .invalidPlan(let reason)?: reason
        default: nil
        }
        let checksum = managedObjectModel(for: ChangedTestSchema.self).versionChecksum
        #expect(reason?.contains(checksum) == true)
    }

    private func isInvalidPlan(_ error: MigrationError?) -> Bool {
        switch error {
        case .invalidPlan?: true
        default: false
        }
    }
}
