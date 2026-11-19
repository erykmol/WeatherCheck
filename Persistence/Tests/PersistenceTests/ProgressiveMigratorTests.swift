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

@MainActor
struct ProgressiveMigratorTests {
    @Test func doesNothingWithoutAStore() throws {
        let store = try TestStore()
        let sut = ProgressiveMigrator(currentModel: managedObjectModel(for: TestSchemaV5.self))

        try sut.migrateStoreIfNeeded(at: store.url) { () throws(MigrationError) in throw .unknownStoreVersion }

        #expect(!store.fileExists(at: store.url))
    }

    @Test func leavesAStoreOnTheCurrentModelAsItIs() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(current, with: [["title": "Apples", "amount": 2.5, "unit": "kg"]])
        let sut = ProgressiveMigrator(currentModel: current)

        try sut.migrateStoreIfNeeded(at: store.url) { () throws(MigrationError) in throw .unknownStoreVersion }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "kg")])
    }

    @Test func goesThroughEveryStepFromTheFirstVersion() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [
            ["label": "Apples", "amount": "2.5"],
            ["label": "Pears", "amount": "3"],
        ])
        let steps = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator(currentModel: current)

        try sut.migrateStoreIfNeeded(at: store.url) { steps }

        #expect(try store.items(current) == [
            TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs"),
            TestItem(title: "Pears", note: nil, amount: 3, unit: "pcs"),
        ])
        #expect(!store.fileExists(at: ProgressiveMigrator.temporaryStoreURL(for: store.url)))
    }

    @Test func startsFromTheVersionTheStoreIsOn() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV3.self), with: [["title": "Apples", "amount": "2.5", "note": "Fresh"]])
        let steps = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator(currentModel: current)

        try sut.migrateStoreIfNeeded(at: store.url) { steps }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: "Fresh", amount: 2.5, unit: "pcs")])
    }

    @Test func stopsAtTheStepThatFails() throws {
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let steps = try MigrationStepBuilder.steps(for: FailingTestMigrationPlan.self)
        let sut = ProgressiveMigrator(currentModel: managedObjectModel(for: TestSchemaV5.self))

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url) { steps }
        }

        guard case .stepFailed(let step, _)? = error else {
            Issue.record("Expected a failed step, got \(String(describing: error))")
            return
        }
        #expect(step == 2)
        #expect(try store.isOn(managedObjectModel(for: TestSchemaV3.self)))
        #expect(!store.fileExists(at: ProgressiveMigrator.temporaryStoreURL(for: store.url)))
    }

    @Test func carriesOnWhereAFailedRunStopped() throws {
        let current = managedObjectModel(for: TestSchemaV5.self)
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let failing = try MigrationStepBuilder.steps(for: FailingTestMigrationPlan.self)
        let working = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator(currentModel: current)
        try? sut.migrateStoreIfNeeded(at: store.url) { failing }

        try sut.migrateStoreIfNeeded(at: store.url) { working }

        #expect(try store.items(current) == [TestItem(title: "Apples", note: nil, amount: 2.5, unit: "pcs")])
    }

    @Test func failsWhenTheStepsStopBeforeTheCurrentModel() throws {
        let store = try TestStore()
        try store.seed(managedObjectModel(for: TestSchemaV1.self), with: [["label": "Apples", "amount": "2.5"]])
        let steps = Array(try MigrationStepBuilder.steps(for: TestMigrationPlan.self).prefix(2))
        let sut = ProgressiveMigrator(currentModel: managedObjectModel(for: TestSchemaV5.self))

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url) { steps }
        }

        guard case .incompleteMigration? = error else {
            Issue.record("Expected an incomplete migration, got \(String(describing: error))")
            return
        }
    }

    @Test func rejectsAStoreFromAnUnknownVersion() throws {
        let store = try TestStore()
        try store.seed(unrelatedManagedObjectModel(), with: [])
        let steps = try MigrationStepBuilder.steps(for: TestMigrationPlan.self)
        let sut = ProgressiveMigrator(currentModel: managedObjectModel(for: TestSchemaV5.self))

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url) { steps }
        }

        guard case .unknownStoreVersion? = error else {
            Issue.record("Expected an unknown store version, got \(String(describing: error))")
            return
        }
    }

    @Test func rejectsAFileThatIsNotAStore() throws {
        let store = try TestStore()
        try Data("not a database".utf8).write(to: store.url)
        let sut = ProgressiveMigrator(currentModel: managedObjectModel(for: TestSchemaV5.self))

        let error = #expect(throws: MigrationError.self) {
            try sut.migrateStoreIfNeeded(at: store.url) { () throws(MigrationError) in [] }
        }

        guard case .unreadableStore? = error else {
            Issue.record("Expected an unreadable store, got \(String(describing: error))")
            return
        }
    }
}
