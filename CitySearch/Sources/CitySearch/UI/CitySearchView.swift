//
//  CitySearchView.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem
import Networking

public struct CitySearchView: View {
    @State private var viewModel: CitySearchViewModel
    @State private var isConfirmingClear = false

    public init(history: any SearchHistoryStoring, onCitySelected: @escaping (City) -> Void) {
        self.init(viewModel: CitySearchViewModel(
            validator: CityNameValidator(),
            networkMonitor: NetworkMonitor(),
            history: history,
            onCitySelected: onCitySelected
        ))
    }

    init(viewModel: CitySearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .navigationTitle(Localizable.searchTitle)
            .searchable(
                text: $viewModel.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Localizable.searchPrompt
            )
            .autocorrectionDisabled()
            .task { viewModel.loadHistory() }
            .task { await viewModel.observeConnectivity() }
            .task(id: viewModel.request) { await viewModel.search() }
            .confirmationDialog(
                Localizable.clearHistoryDialogTitle,
                isPresented: $isConfirmingClear,
                titleVisibility: .visible
            ) {
                Button(role: .destructive) {
                    viewModel.clearHistory()
                } label: {
                    Localizable.clearHistoryDialogButton
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.content {
        case .idle:
            if viewModel.history.isEmpty && !viewModel.isOffline {
                EmptyHistoryView()
            } else {
                HistoryList(
                    cities: viewModel.history,
                    isOffline: viewModel.isOffline,
                    onSelect: { viewModel.select($0) },
                    onRemove: { viewModel.remove($0) },
                    onClear: { isConfirmingClear = true }
                )
            }
        case .searching:
            SearchingView()
        case .results(let cities):
            ResultsList(
                cities: cities,
                query: viewModel.query,
                isOffline: viewModel.isOffline,
                onSelect: { viewModel.select($0) }
            )
        case .noResults(let query):
            NoResultsView(query: query)
        case .invalidName:
            InvalidNameView(message: Localizable.invalidNameErrorMessage)
        case .nameTooLong:
            InvalidNameView(message: Localizable.nameTooLongErrorMessage)
        case .failed(let message):
            SearchFailedView(message: message, onRetry: { viewModel.retry() })
        }
    }
}

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
    }
}

struct OfflineSection: View {
    var body: some View {
        Section {
            OfflineBanner()
        }
        .listRowBackground(Palette.warningBackground)
    }
}

struct OfflineBanner: View {

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: Constants.messageSpacing) {
                Localizable.noInternetErrorTitle
                    .font(Typography.secondaryEmphasized)
                Localizable.noInternetErrorMessage
                    .font(Typography.footnote)
            }
        } icon: {
            Image(systemName: Constants.offlineIcon)
                .foregroundStyle(Palette.warning)
        }
        .foregroundStyle(Palette.textPrimary)
        .accessibilityElement(children: .combine)
    }
}

struct EmptyHistoryView: View {

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.emptyHistoryTitle
            } icon: {
                Image(systemName: Constants.emptyIcon)
            }
        } description: {
            Localizable.emptyHistoryMessage
        }
    }
}

struct SearchingView: View {

    var body: some View {
        ProgressView {
            Localizable.searchingTitle
        }
        .tint(Palette.textSecondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, Constants.searchingTopPadding)
        .background(Palette.background)
    }
}

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

struct InvalidNameView: View {
    private let message: Text

    init(message: Text) {
        self.message = message
    }

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: Constants.messageSpacing) {
                        Localizable.invalidNameErrorTitle
                            .font(Typography.headline)
                        message
                            .font(Typography.secondary)
                            .foregroundStyle(Palette.textSecondary)
                    }
                } icon: {
                    Image(systemName: Constants.invalidIcon)
                        .foregroundStyle(Palette.destructive)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct SearchFailedView: View {
    private let message: String?
    private let onRetry: () -> Void

    init(message: String?, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        List {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: Constants.messageSpacing) {
                        Localizable.searchErrorTitle
                            .font(Typography.headline)
                        Localizable.searchErrorMessage
                            .font(Typography.secondary)
                            .foregroundStyle(Palette.textSecondary)
                        if let message {
                            Localizable.errorDetails(message)
                                .font(Typography.footnote)
                                .foregroundStyle(Palette.textSecondary)
                        }
                    }
                } icon: {
                    Image(systemName: Constants.failedIcon)
                        .foregroundStyle(Palette.warning)
                }
                .accessibilityElement(children: .combine)

                Button {
                    onRetry()
                } label: {
                    Localizable.retryButton
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

struct CityRow: View {
    private let title: AttributedString
    private let subtitle: String
    private let systemImage: String

    init(title: AttributedString, subtitle: String, systemImage: String) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
    }

    var body: some View {
        HStack(spacing: Constants.rowSpacing) {
            Image(systemName: systemImage)
                .font(Typography.icon)
                .foregroundStyle(Palette.textSecondary)
                .frame(width: Constants.rowIconWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: Constants.rowTextSpacing) {
                Text(title)
                    .foregroundStyle(Palette.textPrimary)
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(Typography.secondary)
                        .foregroundStyle(Palette.textSecondary)
                }
            }

            Spacer()

            Image(systemName: Constants.chevronIcon)
                .font(Typography.accessory)
                .foregroundStyle(Palette.lightGray)
                .accessibilityHidden(true)
        }
        .padding(.vertical, Constants.rowVerticalPadding)
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview("History") {
    NavigationStack {
        CitySearchView(viewModel: .preview(history: City.previewCities))
    }
}

#Preview("Empty history") {
    NavigationStack {
        CitySearchView(viewModel: .preview())
    }
}

#Preview("Searching") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: "Łódź", response: .pending))
    }
}

#Preview("Results") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: "Nowa", response: .matching(City.previewSameNameTowns)))
    }
}

#Preview("No results") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: "Kraqow"))
    }
}

#Preview("Invalid name") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: "Kraków1"))
    }
}

#Preview("Name too long") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: String(repeating: "a", count: 101)))
    }
}

#Preview("API error") {
    NavigationStack {
        CitySearchView(viewModel: .preview(
            query: "Łódź",
            response: .failure(.server(message: "Parameter count must be between 1 and 100."))
        ))
    }
}

#Preview("Offline") {
    NavigationStack {
        CitySearchView(viewModel: .preview(query: "Łódź", history: City.previewCities, response: .failure(.offline)))
    }
}
#endif

private enum Constants {
    static let rowSpacing: CGFloat = 12
    static let rowTextSpacing: CGFloat = 2
    static let rowVerticalPadding: CGFloat = 4
    static let rowIconWidth: CGFloat = 28
    static let messageSpacing: CGFloat = 4
    static let searchingTopPadding: CGFloat = 40

    static let historyIcon = "clock.arrow.circlepath"
    static let resultIcon = "mappin.and.ellipse"
    static let emptyIcon = "mappin.and.ellipse"
    static let noResultsIcon = "magnifyingglass"
    static let invalidIcon = "exclamationmark.circle"
    static let failedIcon = "exclamationmark.triangle"
    static let offlineIcon = "wifi.slash"
    static let chevronIcon = "chevron.right"
}
