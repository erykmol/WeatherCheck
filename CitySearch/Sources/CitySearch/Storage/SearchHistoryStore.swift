//
//  SearchHistoryStore.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData
import Persistence

@MainActor
public final class SearchHistoryStore: SearchHistoryStoring {
    private let stack: CoreDataStack
    private let retention: SearchHistoryRetention
    private let now: () -> Date

    private var context: NSManagedObjectContext {
        stack.viewContext
    }

    public convenience init(storage: CoreDataStack.Storage, retention: SearchHistoryRetention) throws {
        let opener = SearchHistoryStackOpener(
            factory: CoreDataStackFactory(plan: SearchHistoryMigrationPlan.self)
        )
        try self.init(
            stack: opener.openStack(storage: storage),
            retention: retention,
            now: { .now }
        )
    }

    init(stack: CoreDataStack, retention: SearchHistoryRetention, now: @escaping () -> Date) {
        self.stack = stack
        self.retention = retention
        self.now = now
    }

    public func load() throws -> [City] {
        let request = retainedEntries()
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).map { City($0) }
    }

    public func record(_ city: City) throws {
        let entity = try context.fetch(CityEntity.fetch(id: city.id)).first ?? CityEntity(insertInto: context)
        entity.update(from: city, searchedAt: now())
        try saveChanges()
        try delete(entriesOutsideRetention())
    }

    public func remove(_ city: City) throws {
        try delete(context.fetch(CityEntity.fetch(id: city.id)))
    }

    public func removeAll() throws {
        try delete(context.fetch(CityEntity.fetchAll()))
    }

    private func retainedEntries() -> NSFetchRequest<CityEntity> {
        let request = CityEntity.fetchNewestFirst()
        if let cutoff = retention.cutoff(before: now()) {
            request.predicate = CityEntity.searched(since: cutoff)
        }
        if let maxCount = retention.maxCount {
            request.fetchLimit = maxCount
        }
        return request
    }

    private func entriesOutsideRetention() throws -> [CityEntity] {
        var outside: [CityEntity] = []
        if let cutoff = retention.cutoff(before: now()) {
            let request = CityEntity.fetchAll()
            request.predicate = NSCompoundPredicate(
                notPredicateWithSubpredicate: CityEntity.searched(since: cutoff)
            )
            outside += try context.fetch(request)
        }
        if let maxCount = retention.maxCount {
            let request = CityEntity.fetchNewestFirst()
            request.fetchOffset = maxCount
            outside += try context.fetch(request)
        }
        return outside
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
}

private extension City {
    init(_ entity: CityEntity) {
        self.init(
            id: Int(entity.cityID),
            name: entity.name,
            region: entity.region,
            country: entity.country,
            latitude: entity.latitude,
            longitude: entity.longitude
        )
    }
}
