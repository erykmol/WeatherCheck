//
//  SearchHistorySchemaV1.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

enum SearchHistorySchemaV1: VersionedSchema {
    static let versionIdentifier = "1"
    static let versionChecksum = "z4r/Axk+X+gqP1Mqhpd1rgS+GAuTt69QSLRZwUsJjtY="

    static func makeEntities() -> [NSEntityDescription] {
        [
            NSEntityDescription(
                name: CityEntity.entityName,
                managedObjectClass: CityEntity.self,
                properties: [
                    NSAttributeDescription(name: #keyPath(CityEntity.cityID), type: .integer64AttributeType, defaultValue: 0),
                    NSAttributeDescription(name: #keyPath(CityEntity.name), type: .stringAttributeType),
                    NSAttributeDescription(name: #keyPath(CityEntity.region), type: .stringAttributeType, isOptional: true),
                    NSAttributeDescription(name: #keyPath(CityEntity.country), type: .stringAttributeType, isOptional: true),
                    NSAttributeDescription(name: #keyPath(CityEntity.latitude), type: .doubleAttributeType, defaultValue: 0.0),
                    NSAttributeDescription(name: #keyPath(CityEntity.longitude), type: .doubleAttributeType, defaultValue: 0.0),
                    NSAttributeDescription(name: #keyPath(CityEntity.lastSearchedAt), type: .dateAttributeType),
                ],
                uniquenessConstraints: [[#keyPath(CityEntity.cityID)]]
            ),
        ]
    }
}
