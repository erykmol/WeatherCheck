//
//  SearchHistoryRecordsProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

@MainActor
public protocol SearchHistoryRecordsProtocol {
    func entries() throws -> [SearchHistoryEntry]

    func save(_ entry: SearchHistoryEntry) throws

    func delete(cityIDs: [Int]) throws

    func deleteAll() throws
}
