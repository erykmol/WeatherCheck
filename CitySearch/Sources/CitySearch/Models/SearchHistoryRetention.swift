//
//  SearchHistoryRetention.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public struct SearchHistoryRetention: Sendable {
    public let maxCount: Int?
    public let maxAge: TimeInterval?

    public init(maxCount: Int? = nil, maxAge: TimeInterval? = nil) {
        precondition(maxCount.map { $0 > 0 } ?? true, "maxCount must be greater than zero")
        precondition(maxAge.map { $0 > 0.0 } ?? true, "maxAge must be greater than zero")
        self.maxCount = maxCount
        self.maxAge = maxAge
    }

    func calculateCutoff(before now: Date) -> Date? {
        maxAge.map { now.addingTimeInterval(-$0) }
    }
}
