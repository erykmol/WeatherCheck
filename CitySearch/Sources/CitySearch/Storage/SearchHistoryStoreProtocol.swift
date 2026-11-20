//
//  SearchHistoryStoreProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

@MainActor
public protocol SearchHistoryStoreProtocol {
    func load() throws -> [City]

    func record(_ city: City) throws

    func remove(_ city: City) throws

    func removeAll() throws
}
