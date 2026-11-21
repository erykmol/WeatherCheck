//
//  ForecastView.swift
//  Forecast
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem
import Networking

public struct ForecastView: View {
    @State private var viewModel: ForecastViewModel

    public init(location: ForecastLocation) {
        self.init(viewModel: ForecastViewModel(location: location))
    }

    init(viewModel: ForecastViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        content
            .animation(.default, value: viewModel.state)
            .animation(.default, value: viewModel.isOffline)
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background {
                Palette.background.ignoresSafeArea()
            }
            .task {
                await viewModel.load()
            }
            .task {
                await viewModel.observeConnectivity()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ScrollView {
                ForecastContent(location: viewModel.location, forecast: .placeholder, updatedAt: nil, isOffline: false)
                    .redacted(reason: .placeholder)
            }
            .scrollDisabled(true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Localizable.loadingAccessibilityLabel)
        case .loaded(let forecast, let updatedAt):
            ScrollView {
                ForecastContent(
                    location: viewModel.location,
                    forecast: forecast,
                    updatedAt: updatedAt,
                    isOffline: viewModel.isOffline
                )
            }
            .refreshable {
                await viewModel.refresh()
            }
        case .offline:
            OfflineView {
                Task { await viewModel.retry() }
            }
        case .failed(let message):
            FailedView(message: message) {
                Task { await viewModel.retry() }
            }
        }
    }
}

#if DEBUG
#Preview("Loading") {
    NavigationStack {
        ForecastView(viewModel: .preview(.pending))
    }
}

#Preview("Loaded") {
    NavigationStack {
        ForecastView(viewModel: .preview(.forecast(.placeholder)))
    }
}

#Preview("Loaded offline") {
    NavigationStack {
        ForecastView(viewModel: .preview(.forecast(.placeholder), connectivity: [.disconnected]))
    }
}

#Preview("Offline") {
    NavigationStack {
        ForecastView(viewModel: .preview(.failure(.offline)))
    }
}

#Preview("API error") {
    NavigationStack {
        ForecastView(viewModel: .preview(.failure(.server(message: "Latitude must be in range of -90 to 90°."))))
    }
}
#endif
