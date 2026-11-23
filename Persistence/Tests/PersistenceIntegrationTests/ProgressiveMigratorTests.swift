//
//  ProgressiveMigratorTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
@testable import Persistence
import PersistenceTestFixtures

@MainActor
struct ProgressiveMigratorTests {
    @Test func doesNothingWithoutAStore() throws {
        let store = try TestStore()
        let current = managedObjectModel(for: TestSchemaV5.self)
        let sut = ProgressiveMigrator()

        try sut.migrateStoreIfNeeded(at: store.url, to: current) { () throws(MigrationError) in throw .unknownStoreVersion }

        #expect(!store.fileExists(at: store.url))
    }

    @Test func leavesAStoreOnTheCurrentModelAsItIs() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(current, with: [["title": "Apples", "amount": 2.5, "unit": "kg"]])
        let sut = ProgressiveMigrator()

        try sut.migrateStoreIfNeeded(at: store.url, to: current) { () throws(MigrationError) in throw .unknownStoreVersion }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "kg")])
    }

    @Test func goesThroughEveryStepFromTheFirstVersion() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [
            ["label": "Apples", "amount": "2.5"],
            ["label": "Pears", "amount": "3"],
        ])
        let steps = try migrationSteps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator()

        try sut.migrateStoreIfNeeded(at: store.url, to: current) { steps }

        #expect(try store.items(current) == [
            TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs"),
            TestItem(title: "Pears", note: nil, amount: 3.0, unit: "pcs"),
        ])
        #expect(try store.filesBesideTheStore().isEmpty)
    }

    @Test func startsFromTheVersionTheStoreIsOn() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV3.self), with: [["title": "Apples", "amount": "2.5", "note": "Fresh"]])
        let steps = try migrationSteps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator()

        try sut.migrateStoreIfNeeded(at: store.url, to: current) { steps }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: "Fresh", amount: 2.5, unit: "pcs")])
    }

    @Test func stopsAtTheStepThatFails() throws {
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let steps = try migrationSteps(for: FailingTestMigrationPlan.self)
        let current = managedObjectModel(for: TestSchemaV5.self)
        let sut = ProgressiveMigrator()

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url, to: current) { steps }
        }

        guard case .stepFailed(let step, _)? = error else {
            Issue.record("Expected a failed step, got \(String(describing: error))")
            return
        }
        #expect(step == 2)
        #expect(try store.isOn(managedObjectModel(for: TestSchemaV3.self)))
        #expect(try store.filesBesideTheStore().isEmpty)
    }

    @Test func carriesOnWhereAFailedRunStopped() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let failing = try migrationSteps(for: FailingTestMigrationPlan.self)
        let working = try migrationSteps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator()
        try? sut.migrateStoreIfNeeded(at: store.url, to: current) { failing }

        try sut.migrateStoreIfNeeded(at: store.url, to: current) { working }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs")])
    }

    @Test func failsWhenTheStepsStopBeforeTheCurrentModel() throws {
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let steps = Array(try migrationSteps(for: TestMigrationPlan.self).prefix(2))
        let current = managedObjectModel(for: TestSchemaV5.self)
        let sut = ProgressiveMigrator()

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url, to: current) { steps }
        }

        guard case .incompleteMigration? = error else {
            Issue.record("Expected an incomplete migration, got \(String(describing: error))")
            return
        }
    }

    @Test func rejectsAStoreFromAnUnknownVersion() throws {
        let store = try TestStore()
        try store.seed(unrelatedManagedObjectModel(), with: [])
        let steps = try migrationSteps(for: TestMigrationPlan.self)
        let current = managedObjectModel(for: TestSchemaV5.self)
        let sut = ProgressiveMigrator()

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url, to: current) { steps }
        }

        guard case .unknownStoreVersion? = error else {
            Issue.record("Expected an unknown store version, got \(String(describing: error))")
            return
        }
    }

    @Test func rejectsAFileThatIsNotAStore() throws {
        let store = try TestStore()
        try Data("not a database".utf8).write(to: store.url)
        let current = managedObjectModel(for: TestSchemaV5.self)
        let sut = ProgressiveMigrator()

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url, to: current) { () throws(MigrationError) in [] }
        }

        guard case .unreadableStore? = error else {
            Issue.record("Expected an unreadable store, got \(String(describing: error))")
            return
        }
    }
}
