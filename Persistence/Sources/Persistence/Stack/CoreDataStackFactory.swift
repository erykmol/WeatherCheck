//
//  CoreDataStackFactory.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

@MainActor
public struct CoreDataStackFactory: CoreDataStackFactoryProtocol {
    private let plan: any MigrationPlanProtocol.Type

    public init(plan: any MigrationPlanProtocol.Type) {
        self.plan = plan
    }

    public func makeStack(storage: CoreDataStack.Storage) throws -> CoreDataStack {
        try CoreDataStack(plan: plan, storage: storage)
    }
}
