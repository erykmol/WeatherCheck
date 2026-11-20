//
//  WeatherCheckApp.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import OSLog
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
        SearchHistoryStore(records: makeHistoryRecords(), retention: Constants.historyRetention)
    }

    private static func makeHistoryRecords() -> CoreDataSearchHistoryRecords {
        do {
            return try CoreDataSearchHistoryRecords(storage: .applicationSupport(fileName: Constants.historyFileName))
        } catch {
            logger.error("Couldn't open the search history, it won't be kept: \(String(describing: error), privacy: .public)")
        }
        do {
            return try CoreDataSearchHistoryRecords(storage: .inMemory)
        } catch {
            fatalError("Couldn't open an in-memory search history either: \(error)")
        }
    }
}

private enum Constants {
    static let historyFileName = "SearchHistory.sqlite"
    static let historyRetention = SearchHistoryRetention(maxCount: 10)
}
