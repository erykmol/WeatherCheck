//
//  SearchHistoryStoreProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

@MainActor
public protocol SearchHistoryStoreProtocol {
    func loadCities() throws -> [City]

    func saveApplyingRetention(_ city: City) throws

    func delete(_ city: City) throws

    func deleteAll() throws
}
