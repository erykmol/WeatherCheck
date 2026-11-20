//
//  SearchHistoryStoring.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

@MainActor
public protocol SearchHistoryStoring {
    func load() throws -> [City]

    func record(_ city: City) throws

    func remove(_ city: City) throws

    func removeAll() throws
}
