//
//  CoreDataSearchHistoryRecords.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData
import Persistence
import CitySearch

@MainActor
public final class CoreDataSearchHistoryRecords: SearchHistoryRecordsProtocol {
    private let stack: CoreDataStack

    private var context: NSManagedObjectContext {
        stack.viewContext
    }

    public convenience init(storage: CoreDataStack.Storage) throws {
        let opener = SearchHistoryStackOpener(
            factory: CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self)
        )
        try self.init(stack: opener.openStack(storage: storage))
    }

    init(stack: CoreDataStack) {
        self.stack = stack
    }

    public func entries() throws -> [SearchHistoryEntry] {
        let request = CityEntity.fetchAll()
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).map(entry(from:))
    }

    public func save(_ entry: SearchHistoryEntry) throws {
        let entity = try context.fetch(CityEntity.fetch(id: entry.city.id)).first ?? CityEntity(insertInto: context)
        entity.update(from: entry.city, searchedAt: entry.searchedAt)
        try saveChanges()
    }

    public func delete(cityIDs: [Int]) throws {
        try delete(context.fetch(CityEntity.fetch(ids: cityIDs)))
    }

    public func deleteAll() throws {
        try delete(context.fetch(CityEntity.fetchAll()))
    }

    private func delete(_ entities: [CityEntity]) throws {
        for entity in entities {
            context.delete(entity)
        }
        try saveChanges()
    }

    private func saveChanges() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func entry(from entity: CityEntity) -> SearchHistoryEntry {
        SearchHistoryEntry(
            city: City(
                id: Int(entity.cityID),
                name: entity.name,
                region: entity.region,
                country: entity.country,
                latitude: entity.latitude,
                longitude: entity.longitude
            ),
            searchedAt: entity.lastSearchedAt
        )
    }
}
