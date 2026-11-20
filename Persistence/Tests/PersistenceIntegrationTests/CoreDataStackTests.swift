//
//  CoreDataStackTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence
import PersistenceTestHelpers
import PersistenceTestFixtures

@MainActor
struct CoreDataStackTests {
    @Test func namesTheApplicationSupportStoreAfterThePlan() {
        let sut = CoreDataStack.Storage.applicationSupport(for: TestMigrationPlan.self)

        #expect(fileURL(of: sut) == URL.applicationSupportDirectory.appending(path: "TestMigrationPlan.sqlite"))
    }

    @Test func givesEveryPlanItsOwnApplicationSupportStore() {
        let sut = CoreDataStack.Storage.applicationSupport(for: TestMigrationPlan.self)
        let other = CoreDataStack.Storage.applicationSupport(for: RelationTestMigrationPlan.self)

        #expect(fileURL(of: sut) != fileURL(of: other))
    }
}
