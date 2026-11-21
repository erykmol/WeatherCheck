//
//  TemperatureRangeBar.swift
//  Forecast
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct TemperatureRangeBar: View {
    private let range: ClosedRange<Double>
    private let bounds: ClosedRange<Double>

    init(range: ClosedRange<Double>, bounds: ClosedRange<Double>) {
        self.range = range
        self.bounds = bounds
    }

    var body: some View {
        GeometryReader { proxy in
            let span = max(bounds.upperBound - bounds.lowerBound, Constants.minimumSpan)
            let start = (range.lowerBound - bounds.lowerBound) / span
            let length = (range.upperBound - range.lowerBound) / span

            Capsule()
                .fill(Palette.track)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Palette.accent)
                        .frame(width: max(proxy.size.width * length, Constants.rangeBarHeight))
                        .offset(x: proxy.size.width * start)
                }
        }
        .frame(height: Constants.rangeBarHeight)
        .accessibilityHidden(true)
    }
}

private enum Constants {
    static let rangeBarHeight: CGFloat = 5
    static let minimumSpan: Double = 1
}
