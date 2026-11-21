//
//  HistoryList.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct HistoryList: View {
    private let cities: [City]
    private let isOffline: Bool
    private let onSelect: (City) -> Void
    private let onRemove: (City) -> Void
    private let onClear: () -> Void

    init(
        cities: [City],
        isOffline: Bool,
        onSelect: @escaping (City) -> Void,
        onRemove: @escaping (City) -> Void,
        onClear: @escaping () -> Void
    ) {
        self.cities = cities
        self.isOffline = isOffline
        self.onSelect = onSelect
        self.onRemove = onRemove
        self.onClear = onClear
    }

    var body: some View {
        List {
            if isOffline {
                OfflineSection()
            }
            if !cities.isEmpty {
                Section {
                    ForEach(cities) { city in
                        Button {
                            onSelect(city)
                        } label: {
                            CityRow(
                                title: AttributedString(city.name),
                                subtitle: city.subtitle,
                                systemImage: Constants.historyIcon
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onRemove(city)
                            } label: {
                                Localizable.historyRemoveButton
                            }
                        }
                    }
                } header: {
                    HStack {
                        Localizable.historySectionTitle
                        Spacer()
                        Button {
                            onClear()
                        } label: {
                            Localizable.historyClearButton
                        }
                        .font(Typography.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            EmptyHistoryView()
                .opacity(!isOffline && cities.isEmpty ? 1.0 : 0.0)
        }
    }
}

private enum Constants {
    static let historyIcon = "clock.arrow.circlepath"
}
