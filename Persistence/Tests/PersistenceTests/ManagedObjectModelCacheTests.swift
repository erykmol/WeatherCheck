//
//  ManagedObjectModelCacheTests.swift
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
struct ManagedObjectModelCacheTests {
    @Test func buildsEachModelOnce() {
        let modelBuilder = FakeManagedObjectModelBuilder()
        let sut = ManagedObjectModelCache(modelBuilder: modelBuilder)
        let first = sut.bindModel(for: BoundTestSchema.self)

        let second = sut.bindModel(for: BoundTestSchema.self)

        #expect(first === second)
        #expect(modelBuilder.requests.count == 1)
    }

    @Test func asksForAModelWithBoundClasses() {
        let modelBuilder = FakeManagedObjectModelBuilder()
        let sut = ManagedObjectModelCache(modelBuilder: modelBuilder)

        _ = sut.bindModel(for: BoundTestSchema.self)

        #expect(modelBuilder.requests == [.init(schema: ObjectIdentifier(BoundTestSchema.self), bindingClasses: true)])
    }
}
