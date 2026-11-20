//
//  TestMigrationPlans.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

enum TestPlanParts {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [TestSchemaV1.self, TestSchemaV2.self, TestSchemaV3.self, TestSchemaV4.self, TestSchemaV5.self]
    }

    static func stages(itemPolicy: NSEntityMigrationPolicy.Type) -> [MigrationStage] {
        [
            .lightweight(from: TestSchemaV1.self, to: TestSchemaV2.self),
            .lightweight(from: TestSchemaV2.self, to: TestSchemaV3.self),
            .custom(from: TestSchemaV3.self, to: TestSchemaV4.self, policies: [TestEntity.item: itemPolicy]),
            .lightweight(from: TestSchemaV4.self, to: TestSchemaV5.self),
        ]
    }
}

enum TestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        TestPlanParts.schemas
    }

    static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: AmountToNumberPolicy.self)
    }
}

enum FailingTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        TestPlanParts.schemas
    }

    static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: FailingMigrationPolicy.self)
    }
}

enum EmptyTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        []
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum MissingStageTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum MisorderedTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [.lightweight(from: TestSchemaV2.self, to: TestSchemaV1.self)]
    }
}

enum BoundTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [BoundTestSchema.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum ChangedSchemaTestMigrationPlan: MigrationPlanProtocol {
    static var schemas: [any VersionedSchemaProtocol.Type] {
        [ChangedTestSchema.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
