//
//  MigrationStepBuilderTests.swift
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
struct MigrationStepBuilderTests {
    private func makeSUT(
        plan: any MigrationPlanProtocol.Type,
        validator: FakeMigrationPlanValidator = FakeMigrationPlanValidator(),
        modelBuilder: FakeManagedObjectModelBuilder = FakeManagedObjectModelBuilder(),
        mappingModelBuilder: FakeMappingModelBuilder = FakeMappingModelBuilder(),
        modelCache: FakeManagedObjectModelCache = FakeManagedObjectModelCache(model: NSManagedObjectModel())
    ) throws(MigrationError) -> MigrationStepBuilder {
        try MigrationStepBuilder(
            plan: plan,
            validator: validator,
            modelBuilder: modelBuilder,
            mappingModelBuilder: mappingModelBuilder,
            modelCache: modelCache
        )
    }

    @Test func buildsAStepBetweenEveryPairOfSchemas() throws {
        let sut = try makeSUT(plan: TestMigrationPlan.self)

        let steps = try sut.makeSteps()

        let versions = TestPlanParts.schemas.map { Set<AnyHashable>([$0.versionIdentifier]) }
        #expect(steps.map(\.sourceModel.versionIdentifiers) == Array(versions.dropLast()))
        #expect(steps.map(\.destinationModel.versionIdentifiers) == Array(versions.dropFirst()))
    }

    @Test func buildsTheStepsFromModelsWithoutBoundClasses() throws {
        let modelBuilder = FakeManagedObjectModelBuilder()
        let sut = try makeSUT(plan: TestMigrationPlan.self, modelBuilder: modelBuilder)

        _ = try sut.makeSteps()

        #expect(!modelBuilder.requests.isEmpty)
        #expect(modelBuilder.requests.allSatisfy { !$0.bindingClasses })
    }

    @Test func buildsTheMappingOfEachStepFromItsModels() throws {
        let mappingModelBuilder = FakeMappingModelBuilder()
        let sut = try makeSUT(plan: TestMigrationPlan.self, mappingModelBuilder: mappingModelBuilder)

        let steps = try sut.makeSteps()

        let requests = mappingModelBuilder.requests
        #expect(requests.count == steps.count)
        for (step, request) in zip(steps, requests) {
            #expect(step.mappingModel === request.mapping)
            #expect(step.sourceModel === request.source)
            #expect(step.destinationModel === request.destination)
        }
    }

    @Test func takesTheCurrentModelFromTheCache() throws {
        let model = NSManagedObjectModel()
        let cache = FakeManagedObjectModelCache(model: model)
        let sut = try makeSUT(plan: TestMigrationPlan.self, modelCache: cache)

        let currentModel = sut.currentModel

        #expect(currentModel === model)
        #expect(cache.requestedSchemas == [ObjectIdentifier(TestSchemaV5.self)])
    }

    @Test func rejectsAPlanWithoutSchemas() {
        let validator = FakeMigrationPlanValidator()

        let error = #expect(throws: MigrationError.self) {
            _ = try makeSUT(plan: EmptyTestMigrationPlan.self, validator: validator)
        }

        #expect(extractReason(of: error) == "The plan has no schemas")
        #expect(validator.validatedPlans.isEmpty)
    }

    @Test func passesTheValidatorsRejectionOn() {
        let validator = FakeMigrationPlanValidator(error: .invalidPlan(reason: "Stage 0 doesn't go from schema 0 to schema 1"))

        let error = #expect(throws: MigrationError.self) {
            _ = try makeSUT(plan: TestMigrationPlan.self, validator: validator)
        }

        #expect(extractReason(of: error) == "Stage 0 doesn't go from schema 0 to schema 1")
        #expect(validator.validatedPlans == [ObjectIdentifier(TestMigrationPlan.self)])
    }

    @Test func passesAMappingErrorOn() throws {
        let mappingModelBuilder = FakeMappingModelBuilder(error: .noInferredMapping(from: "1", to: "2", underlying: TestFailure()))
        let sut = try makeSUT(plan: TestMigrationPlan.self, mappingModelBuilder: mappingModelBuilder)

        let error = #expect(throws: MigrationError.self) {
            _ = try sut.makeSteps()
        }

        let isNoInferredMapping = switch error {
        case .noInferredMapping?: true
        default: false
        }
        #expect(isNoInferredMapping)
    }

    private func extractReason(of error: MigrationError?) -> String? {
        switch error {
        case .invalidPlan(let reason)?: reason
        default: nil
        }
    }
}

private struct TestFailure: Error {}
