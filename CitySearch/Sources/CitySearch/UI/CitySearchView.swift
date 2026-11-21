//
//  CitySearchView.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import Networking

public struct CitySearchView: View {
    @State private var viewModel: CitySearchViewModel
    @State private var isConfirmingClear = false

    public init(history: any SearchHistoryStoreProtocol, onCitySelected: @escaping (City) -> Void) {
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
            .task(id: viewModel.request) { await viewModel.searchIfNeeded() }
            .alert(
                Localizable.clearHistoryAlertTitle,
                isPresented: $isConfirmingClear
            ) {
                Button(role: .destructive) {
                    withAnimation { viewModel.clearHistory() }
                } label: {
                    Localizable.clearHistoryAlertButton
                }
                Button(role: .cancel, action: {}) {
                    Localizable.cancel
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.content {
        case .idle:
            HistoryList(
                cities: viewModel.history,
                isOffline: viewModel.isOffline,
                onSelect: { viewModel.select($0) },
                onRemove: { city in withAnimation { viewModel.remove(city) } },
                onClear: { isConfirmingClear = true }
            )
        case .searching:
            SearchingView()
        case .results(let cities, _):
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
