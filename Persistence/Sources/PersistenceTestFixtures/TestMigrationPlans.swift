//
//  TestMigrationPlans.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

public enum TestPlanParts {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
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

public enum TestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        TestPlanParts.schemas
    }

    public static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: AmountToNumberPolicy.self)
    }
}

public enum FailingTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        TestPlanParts.schemas
    }

    public static var stages: [MigrationStage] {
        TestPlanParts.stages(itemPolicy: FailingMigrationPolicy.self)
    }
}

public enum EmptyTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        []
    }

    public static var stages: [MigrationStage] {
        []
    }
}

public enum MissingStageTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}

public enum MisorderedTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        [TestSchemaV1.self, TestSchemaV2.self]
    }

    public static var stages: [MigrationStage] {
        [.lightweight(from: TestSchemaV2.self, to: TestSchemaV1.self)]
    }
}

public enum BoundTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        [BoundTestSchema.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}

public enum ChangedSchemaTestMigrationPlan: MigrationPlanProtocol {
    public static var schemas: [any VersionedSchemaProtocol.Type] {
        [ChangedTestSchema.self]
    }

    public static var stages: [MigrationStage] {
        []
    }
}
