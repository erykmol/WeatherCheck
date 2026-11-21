//
//  ResultsList.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI

struct ResultsList: View {
    private let cities: [City]
    private let query: String
    private let isOffline: Bool
    private let onSelect: (City) -> Void

    init(cities: [City], query: String, isOffline: Bool, onSelect: @escaping (City) -> Void) {
        self.cities = cities
        self.query = query
        self.isOffline = isOffline
        self.onSelect = onSelect
    }

    var body: some View {
        List {
            if isOffline {
                OfflineSection()
            }
            Section {
                ForEach(cities) { city in
                    Button {
                        onSelect(city)
                    } label: {
                        CityRow(
                            title: highlighted(city.name),
                            subtitle: city.subtitle,
                            systemImage: Constants.resultIcon
                        )
                    }
                }
            } header: {
                Localizable.resultsSectionTitle
            }
        }
        .listStyle(.insetGrouped)
    }

    private func highlighted(_ name: String) -> AttributedString {
        var title = AttributedString(name)
        let typed = query.trimmingCharacters(in: .whitespaces)
        guard !typed.isEmpty,
              let range = title.range(of: typed, options: [.caseInsensitive, .diacriticInsensitive, .anchored])
        else { return title }
        title[range].font = .body.weight(.semibold)
        return title
    }
}

private enum Constants {
    static let resultIcon = "mappin.and.ellipse"
}
