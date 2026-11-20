//
//  MappingModelBuilderProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData

protocol MappingModelBuilderProtocol {
    func mappingModel(
        for stage: MigrationStage,
        from source: NSManagedObjectModel,
        to destination: NSManagedObjectModel
    ) throws(MigrationError) -> NSMappingModel
}
