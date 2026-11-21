//
//  NoResultsView.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI

struct NoResultsView: View {
    private let query: String

    init(query: String) {
        self.query = query
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.noResultsTitle(query)
            } icon: {
                Image(systemName: Constants.noResultsIcon)
            }
        } description: {
            Localizable.noResultsMessage
        }
    }
}

private enum Constants {
    static let noResultsIcon = "magnifyingglass"
}
