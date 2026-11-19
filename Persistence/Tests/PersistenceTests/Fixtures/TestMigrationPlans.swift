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
    static var schemas: [any VersionedSchema.Type] {
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

enum TestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        TestPlanParts.schemas
    }

    static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: AmountToNumberPolicy.self)
    }
}

enum FailingTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        TestPlanParts.schemas
    }

    static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: FailingMigrationPolicy.self)
    }
}

enum EmptyTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        []
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum MissingStageTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum MisorderedTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [.lightweight(from: TestSchemaV2.self, to: TestSchemaV1.self)]
    }
}

enum BoundTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BoundTestSchema.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum ChangedSchemaTestMigrationPlan: MigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ChangedTestSchema.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
