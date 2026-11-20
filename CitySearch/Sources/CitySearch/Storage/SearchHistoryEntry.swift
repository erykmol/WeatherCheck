//
//  SearchHistoryEntry.swift
//  CitySearch
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

public struct SearchHistoryEntry: Equatable, Sendable {
    public let city: City
    public let searchedAt: Date

    public init(city: City, searchedAt: Date) {
        self.city = city
        self.searchedAt = searchedAt
    }
}
