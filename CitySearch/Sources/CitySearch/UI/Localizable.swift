//
//  Localizable.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import SwiftUI

enum Localizable {
    static var searchTitle: Text { Text("search_title", bundle: .module) }
    static var searchPrompt: Text { Text("search_prompt", bundle: .module) }
    static var searchingTitle: Text { Text("searching_title", bundle: .module) }
    static var resultsSectionTitle: Text { Text("results_section_title", bundle: .module) }

    static var historySectionTitle: Text { Text("history_section_title", bundle: .module) }
    static var historyClearButton: Text { Text("history_clear_button", bundle: .module) }
    static var historyRemoveButton: Text { Text("history_remove_button", bundle: .module) }
    static var clearHistoryAlertTitle: Text { Text("clear_history_alert_title", bundle: .module) }
    static var clearHistoryAlertButton: Text { Text("clear_history_alert_button", bundle: .module) }

    static var emptyHistoryTitle: Text { Text("empty_history_title", bundle: .module) }
    static var emptyHistoryMessage: Text { Text("empty_history_message", bundle: .module) }

    static func noResultsTitle(_ query: String) -> Text {
        Text("no_results_title \(query)", bundle: .module)
    }
    static var noResultsMessage: Text { Text("no_results_message", bundle: .module) }

    static var invalidNameErrorTitle: Text { Text("invalid_name_error_title", bundle: .module) }
    static var invalidNameErrorMessage: Text { Text("invalid_name_error_message", bundle: .module) }
    static var nameTooLongErrorMessage: Text { Text("name_too_long_error_message", bundle: .module) }

    static var noInternetErrorTitle: Text { Text("no_internet_error_title", bundle: .module) }
    static var noInternetErrorMessage: Text { Text("no_internet_error_message", bundle: .module) }

    static var searchErrorTitle: Text { Text("search_error_title", bundle: .module) }
    static var searchErrorMessage: Text { Text("search_error_message", bundle: .module) }
    static func errorDetails(_ details: String) -> Text {
        Text("error_details \(details)", bundle: .module)
    }
    static var retryButton: Text { Text("retry_button", bundle: .module) }
    
    static var cancel: Text { Text("Cancel", bundle: .module) }
}
