//
//  CoreDataStackFactoryTests.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
import CoreData
import Persistence
import PersistenceTestFixtures

@MainActor
struct CoreDataStackFactoryTests {
    @Test func makesAStackOnThePlansCurrentSchema() throws {
        let sut = CoreDataStackFactory(plan: TestMigrationPlan.self)

        let stack = try sut.makeStack(storage: .inMemory)

        let model = stack.viewContext.persistentStoreCoordinator?.managedObjectModel
        #expect(model?.versionChecksum == TestSchemaV5.versionChecksum)
    }
}
