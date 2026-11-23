//
//  SearchHistoryStore.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

@MainActor
public final class SearchHistoryStore: SearchHistoryStoreProtocol {
    private let records: any SearchHistoryRecordsProtocol
    private let retention: SearchHistoryRetention
    private let now: () -> Date

    public convenience init(records: any SearchHistoryRecordsProtocol, retention: SearchHistoryRetention) {
        self.init(records: records, retention: retention, now: { .now })
    }

    init(
        records: any SearchHistoryRecordsProtocol,
        retention: SearchHistoryRetention,
        now: @escaping () -> Date
    ) {
        self.records = records
        self.retention = retention
        self.now = now
    }

    public func loadCities() throws -> [City] {
        let entries = try records.loadEntries()
        return applyRetention(to: entries).map(\.city)
    }

    public func saveApplyingRetention(_ city: City) throws {
        try records.save(SearchHistoryEntry(city: city, searchedAt: now()))
        let entries = try records.loadEntries()
        let retainedIDs = Set(applyRetention(to: entries).map(\.city.id))
        let outsideIDs = entries.map(\.city.id).filter { !retainedIDs.contains($0) }
        guard !outsideIDs.isEmpty else { return }
        try records.delete(cityIDs: outsideIDs)
    }

    public func delete(_ city: City) throws {
        try records.delete(cityIDs: [city.id])
    }

    public func deleteAll() throws {
        try records.deleteAll()
    }

    private func applyRetention(to entries: [SearchHistoryEntry]) -> [SearchHistoryEntry] {
        let cutoff = retention.calculateCutoff(before: now())
        let newestFirst = entries
            .filter { entry in cutoff.map { entry.searchedAt >= $0 } ?? true }
            .sorted { $0.searchedAt > $1.searchedAt }
        guard let maxCount = retention.maxCount else { return newestFirst }
        return Array(newestFirst.prefix(maxCount))
    }
}
