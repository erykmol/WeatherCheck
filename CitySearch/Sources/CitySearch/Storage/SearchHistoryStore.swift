//
//  SearchHistoryStore.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

@MainActor
public final class SearchHistoryStore: SearchHistoryStoring {
    private let records: any SearchHistoryRecordsProtocol
    private let retention: SearchHistoryRetention
    private let now: () -> Date

    public convenience init(records: any SearchHistoryRecordsProtocol, retention: SearchHistoryRetention) {
        self.init(records: records, retention: retention, now: { .now })
    }

    init(records: any SearchHistoryRecordsProtocol, retention: SearchHistoryRetention, now: @escaping () -> Date) {
        self.records = records
        self.retention = retention
        self.now = now
    }

    public func load() throws -> [City] {
        let entries = try records.entries()
        return retained(entries).map(\.city)
    }

    public func record(_ city: City) throws {
        try records.save(SearchHistoryEntry(city: city, searchedAt: now()))
        let entries = try records.entries()
        let retainedIDs = Set(retained(entries).map(\.city.id))
        let outsideIDs = entries.map(\.city.id).filter { !retainedIDs.contains($0) }
        guard !outsideIDs.isEmpty else { return }
        try records.delete(cityIDs: outsideIDs)
    }

    public func remove(_ city: City) throws {
        try records.delete(cityIDs: [city.id])
    }

    public func removeAll() throws {
        try records.deleteAll()
    }

    private func retained(_ entries: [SearchHistoryEntry]) -> [SearchHistoryEntry] {
        let cutoff = retention.cutoff(before: now())
        let newestFirst = entries
            .filter { entry in cutoff.map { entry.searchedAt >= $0 } ?? true }
            .sorted { $0.searchedAt > $1.searchedAt }
        guard let maxCount = retention.maxCount else { return newestFirst }
        return Array(newestFirst.prefix(maxCount))
    }
}
