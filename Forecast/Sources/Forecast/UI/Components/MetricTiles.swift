//
//  MetricTiles.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct MetricTiles: View {
    private let current: WeatherForecast.Current

    init(current: WeatherForecast.Current) {
        self.current = current
    }

    var body: some View {
        HStack(spacing: Spacing.xLarge) {
            MetricTile(
                title: Localizable.cloudCoverTileTitle,
                systemImage: Constants.cloudIcon,
                percent: current.cloudCover,
                caption: CloudCoverDescription.makeTitle(for: current.cloudCover),
                tint: Palette.textSecondary
            )
            MetricTile(
                title: Localizable.rainChanceTileTitle,
                systemImage: Constants.rainIcon,
                percent: current.rainChance,
                caption: Localizable.rainChanceTileCaption,
                tint: Palette.rain
            )
        }
    }
}

private enum Constants {
    static let cloudIcon = "cloud.fill"
    static let rainIcon = "umbrella.fill"
}
