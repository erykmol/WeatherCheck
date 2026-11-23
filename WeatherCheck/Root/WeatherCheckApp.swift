//
//  WeatherCheckApp.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import CitySearch
import CitySearchStorage
import Persistence

@main
struct WeatherCheckApp: App {
    private let history: SearchHistoryStore

    init() {
        history = Self.makeHistory()
    }

    var body: some Scene {
        WindowGroup {
            RootView(history: history)
        }
    }

    private static func makeHistory() -> SearchHistoryStore {
        SearchHistoryStore(
            records: SearchHistoryRecordsFactory().makeRecordsWithMemoryAndUnsavedFallbacks(storage: .searchHistory),
            retention: Constants.historyRetention
        )
    }
}

private enum Constants {
    static let historyRetention = SearchHistoryRetention(maxCount: 10)
}
