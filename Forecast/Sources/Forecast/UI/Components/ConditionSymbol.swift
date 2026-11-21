//
//  ConditionSymbol.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct ConditionSymbol: View {
    private let condition: WeatherCondition
    private let isDay: Bool

    init(condition: WeatherCondition, isDay: Bool) {
        self.condition = condition
        self.isDay = isDay
    }

    var body: some View {
        let layers = layerColors
        Image(systemName: condition.symbolName(isDay: isDay))
            .symbolRenderingMode(.palette)
            .foregroundStyle(layers.primary, layers.secondary, layers.tertiary)
    }

    private var layerColors: (primary: Color, secondary: Color, tertiary: Color) {
        switch condition {
        case .clear:
            (Palette.sun, Palette.sun, Palette.sun)
        case .mainlyClear, .partlyCloudy:
            (Palette.cloud, Palette.sun, Palette.sun)
        case .overcast, .fog, .unknown:
            (Palette.cloud, Palette.cloud, Palette.cloud)
        case .drizzle, .rain, .heavyRain, .snow:
            (Palette.cloud, Palette.rain, Palette.rain)
        case .thunderstorm:
            (Palette.cloud, Palette.sun, Palette.rain)
        }
    }
}

#if DEBUG
#Preview("All conditions") {
    let conditions: [WeatherCondition] = [
        .clear, .mainlyClear, .partlyCloudy, .overcast, .fog, .drizzle,
        .rain, .heavyRain, .snow, .thunderstorm, .unknown
    ]
    Grid(horizontalSpacing: Spacing.xxLarge, verticalSpacing: Spacing.medium) {
        ForEach(conditions.indices, id: \.self) { index in
            GridRow {
                ConditionSymbol(condition: conditions[index], isDay: true)
                ConditionSymbol(condition: conditions[index], isDay: false)
                conditions[index].title
                    .font(Typography.secondary)
                    .gridColumnAlignment(.leading)
            }
        }
    }
    .font(Typography.largeIcon)
    .padding(Padding.medium)
    .background(Palette.card)
}
#endif
