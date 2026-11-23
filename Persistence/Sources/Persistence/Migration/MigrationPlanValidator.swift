//
//  MigrationPlanValidator.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

struct MigrationPlanValidator: MigrationPlanValidatorProtocol {
    private let modelBuilder: any ManagedObjectModelBuilderProtocol

    init(modelBuilder: any ManagedObjectModelBuilderProtocol) {
        self.modelBuilder = modelBuilder
    }

    func validate(
        _ plan: any MigrationPlanProtocol.Type
    ) throws(MigrationError) {
        let schemas = plan.schemas
        let stages = plan.stages
        guard stages.count == schemas.count - 1 else {
            throw .invalidPlan(
                reason: "\(schemas.count) schemas need \(schemas.count - 1) stages, found \(stages.count)"
            )
        }
        for (index, stage) in stages.enumerated() {
            guard
                ObjectIdentifier(stage.source) == ObjectIdentifier(schemas[index]),
                ObjectIdentifier(stage.destination) == ObjectIdentifier(schemas[index + 1])
            else {
                throw .invalidPlan(
                    reason: "Stage \(index) doesn't go from schema \(index) to schema \(index + 1)"
                )
            }
        }
        try validateChecksums(of: schemas)
    }

    private func validateChecksums(
        of schemas: [any VersionedSchemaProtocol.Type]
    ) throws(MigrationError) {
        let changes = schemas.compactMap { (schema: any VersionedSchemaProtocol.Type) -> String? in
            let checksum = modelBuilder.makeImmutableModel(for: schema, bindingClasses: false).versionChecksum
            guard checksum != schema.versionChecksum else {
                return nil
            }
            return #"\#(schema) has checksum "\#(checksum)" but declares "\#(schema.versionChecksum)""#
        }
        guard changes.isEmpty else {
            throw .invalidPlan(
                reason: "A versioned schema changed, add a new version instead: \(changes.joined(separator: "; "))"
            )
        }
    }
}
