//
//  SearchHistoryRetentionTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Testing
@testable import CitySearch

struct SearchHistoryRetentionTests {
    @Test func cutsOffAtTheMaximumAgeBeforeNow() {
        let sut = SearchHistoryRetention(maxAge: 60.0)

        let cutoff = sut.cutoff(before: Date(timeIntervalSinceReferenceDate: 1_000.0))

        #expect(cutoff == Date(timeIntervalSinceReferenceDate: 940.0))
    }

    @Test func hasNoCutoffWithoutAMaximumAge() {
        let sut = SearchHistoryRetention(maxCount: 10)

        let cutoff = sut.cutoff(before: .now)

        #expect(cutoff == nil)
    }
}
