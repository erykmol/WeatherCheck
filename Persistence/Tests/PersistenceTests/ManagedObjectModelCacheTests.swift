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

@MainActor
struct ManagedObjectModelCacheTests {
    @Test func returnsTheSameModelEveryTime() {
        let sut = ManagedObjectModelCache()
        let first = sut.bindModel(for: BoundTestSchema.self)

        let second = sut.bindModel(for: BoundTestSchema.self)

        #expect(first === second)
    }

    @Test func bindsTheEntityClasses() {
        let sut = ManagedObjectModelCache()

        let model = sut.bindModel(for: BoundTestSchema.self)

        #expect(model.entitiesByName["Bound"]?.managedObjectClassName == NSStringFromClass(BoundTestObject.self))
    }
}
