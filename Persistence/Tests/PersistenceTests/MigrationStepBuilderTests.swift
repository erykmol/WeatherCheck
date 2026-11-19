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
        let steps = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)

        let models = TestPlanParts.schemas.map { managedObjectModel(for: $0) }
        #expect(steps.map(\.sourceModel) == Array(models.dropLast()))
        #expect(steps.map(\.destinationModel) == Array(models.dropFirst()))
    }

    @Test func copiesEntitiesWithoutAPolicyInACustomStage() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let source = managedObjectModel(for: TestSchemaV3.self)
        let store = try TestStore()
        try store.seed(source, with: [["title": "Apples", "amount": "2.5"]])
        try store.seed(source, entity: TestEntity.tag, with: [["name": "Fruit"]])
        let steps = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)

        try ProgressiveMigrator(currentModel: current).migrateStoreIfNeeded(at: store.url) { steps }

        #expect(try store.tagNames(current) == ["Fruit"])
    }

    @Test func copiesRelationshipsInACustomStage() throws {
        let current = managedObjectModel(for: RelationTestSchemaV2.self)
        let store = try TestStore()
        try store.seedOwner(named: "Ala", withPetNamed: "Burek", in: managedObjectModel(for: RelationTestSchemaV1.self))
        let steps = try MigrationStepBuilder.steps(for: RelationTestMigrationPlan.self)

        try ProgressiveMigrator(currentModel: current).migrateStoreIfNeeded(at: store.url) { steps }

        #expect(try store.petOwnerNames(current) == ["Ala"])
    }

    @Test func usesTheEntityClassesInTheCurrentModel() throws {
        let model = try MigrationStepBuilder.currentModel(of: BoundTestMigrationPlan.self)

        #expect(model.entitiesByName["Bound"]?.managedObjectClassName == NSStringFromClass(BoundTestObject.self))
    }

    @Test func rejectsAPlanWithoutSchemas() {
        let error = #expect(throws: MigrationError.self) {
            try MigrationStepBuilder.steps(for: EmptyTestMigrationPlan.self)
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsAPlanWithAMissingStage() {
        let error = #expect(throws: MigrationError.self) {
            try MigrationStepBuilder.steps(for: MissingStageTestMigrationPlan.self)
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsStagesThatDoNotFollowTheSchemaOrder() {
        let error = #expect(throws: MigrationError.self) {
            try MigrationStepBuilder.steps(for: MisorderedTestMigrationPlan.self)
        }

        #expect(isInvalidPlan(error))
    }

    @Test func rejectsAChangedSchemaAndNamesItsActualChecksum() {
        let error = #expect(throws: MigrationError.self) {
            try MigrationStepBuilder.currentModel(of: ChangedSchemaTestMigrationPlan.self)
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
