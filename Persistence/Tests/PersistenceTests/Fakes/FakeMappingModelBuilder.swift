//
//  FakeMappingModelBuilder.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData
@testable import Persistence

final class FakeMappingModelBuilder: MappingModelBuilderProtocol {
    struct Request {
        let source: NSManagedObjectModel
        let destination: NSManagedObjectModel
        let mapping: NSMappingModel
    }

    private let error: MigrationError?
    private(set) var requests: [Request] = []

    init(error: MigrationError? = nil) {
        self.error = error
    }

    func makeMappingModel(
        for stage: MigrationStage,
        from source: NSManagedObjectModel,
        to destination: NSManagedObjectModel
    ) throws(MigrationError) -> NSMappingModel {
        if let error {
            throw error
        }
        let mapping = NSMappingModel()
        requests.append(Request(source: source, destination: destination, mapping: mapping))
        return mapping
    }
}
