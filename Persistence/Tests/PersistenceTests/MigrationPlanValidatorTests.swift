//
//  MigrationPlanValidatorTests.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
@testable import Persistence
import PersistenceTestFixtures

struct MigrationPlanValidatorTests {
    @Test func acceptsAValidPlan() {
        let sut = MigrationPlanValidator(modelBuilder: FakeManagedObjectModelBuilder())

        #expect(throws: Never.self) {
            try sut.validate(TestMigrationPlan.self)
        }
    }

    @Test func comparesTheChecksumsOfModelsWithoutBoundClasses() throws {
        let modelBuilder = FakeManagedObjectModelBuilder()
        let sut = MigrationPlanValidator(modelBuilder: modelBuilder)

        try sut.validate(TestMigrationPlan.self)

        #expect(modelBuilder.requests.map(\.schema) == TestPlanParts.schemas.map { ObjectIdentifier($0) })
        #expect(modelBuilder.requests.allSatisfy { !$0.bindingClasses })
    }

    @Test func rejectsAPlanWithAMissingStage() {
        let sut = MigrationPlanValidator(modelBuilder: FakeManagedObjectModelBuilder())

        let error = #expect(throws: MigrationError.self) {
            try sut.validate(MissingStageTestMigrationPlan.self)
        }

        #expect(reason(of: error) != nil)
    }

    @Test func rejectsStagesThatDoNotFollowTheSchemaOrder() {
        let sut = MigrationPlanValidator(modelBuilder: FakeManagedObjectModelBuilder())

        let error = #expect(throws: MigrationError.self) {
            try sut.validate(MisorderedTestMigrationPlan.self)
        }

        #expect(reason(of: error) != nil)
    }

    @Test func rejectsAChangedSchemaAndNamesItsActualChecksum() {
        let sut = MigrationPlanValidator(modelBuilder: FakeManagedObjectModelBuilder())

        let error = #expect(throws: MigrationError.self) {
            try sut.validate(ChangedSchemaTestMigrationPlan.self)
        }

        let checksum = managedObjectModel(for: ChangedTestSchema.self).versionChecksum
        #expect(reason(of: error)?.contains(checksum) == true)
    }

    private func reason(of error: MigrationError?) -> String? {
        switch error {
        case .invalidPlan(let reason)?: reason
        default: nil
        }
    }
}
