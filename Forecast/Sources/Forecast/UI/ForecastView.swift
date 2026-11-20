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
                ForecastContent(location: viewModel.location, forecast: .placeholder, updatedAt: nil)
                    .redacted(reason: .placeholder)
            }
            .scrollDisabled(true)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Localizable.loadingAccessibilityLabel)
        case .loaded(let forecast, let updatedAt):
            ScrollView {
                ForecastContent(location: viewModel.location, forecast: forecast, updatedAt: updatedAt)
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

struct ForecastContent: View {
    private let location: ForecastLocation
    private let forecast: WeatherForecast
    private let updatedAt: Date?

    init(location: ForecastLocation, forecast: WeatherForecast, updatedAt: Date?) {
        self.location = location
        self.forecast = forecast
        self.updatedAt = updatedAt
    }

    var body: some View {
        VStack(spacing: Constants.sectionSpacing) {
            HeroSection(location: location, current: forecast.current, today: forecast.today)
            MetricTiles(current: forecast.current)
            HourlySection(hours: forecast.hours)
            DailySection(days: forecast.days, bounds: forecast.temperatureBounds)
            AttributionFooter(updatedAt: updatedAt)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.bottom, Constants.bottomPadding)
    }
}

struct HeroSection: View {
    private let location: ForecastLocation
    private let current: WeatherForecast.Current
    private let today: WeatherForecast.Day?

    @ScaledMetric(relativeTo: .largeTitle) private var temperatureSize = Typography.displaySize

    init(location: ForecastLocation, current: WeatherForecast.Current, today: WeatherForecast.Day?) {
        self.location = location
        self.current = current
        self.today = today
    }

    var body: some View {
        VStack(spacing: Constants.heroSpacing) {
            VStack(spacing: Constants.heroNameSpacing) {
                Text(location.name)
                    .font(Typography.title)
                    .accessibilityAddTraits(.isHeader)
                if !location.subtitle.isEmpty {
                    Text(location.subtitle)
                        .font(Typography.secondary)
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            .unredacted()

            Text(TemperatureFormat.string(current.temperature))
                .font(Typography.display(size: temperatureSize))
                .monospacedDigit()

            Label {
                current.condition.title
            } icon: {
                Image(systemName: current.condition.symbolName(isDay: current.isDay))
                    .symbolRenderingMode(.multicolor)
            }
            .font(Typography.prominent)

            if let today {
                Localizable.todayTemperatureRange(
                    max: TemperatureFormat.string(today.maxTemperature),
                    min: TemperatureFormat.string(today.minTemperature)
                )
                .font(Typography.secondary)
                .foregroundStyle(Palette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Constants.heroTopPadding)
        .accessibilityElement(children: .combine)
    }
}

struct MetricTiles: View {
    private let current: WeatherForecast.Current

    init(current: WeatherForecast.Current) {
        self.current = current
    }

    var body: some View {
        HStack(spacing: Constants.tileSpacing) {
            MetricTile(
                title: Localizable.cloudCoverTileTitle,
                systemImage: Constants.cloudIcon,
                percent: current.cloudCover,
                caption: CloudCoverDescription.title(for: current.cloudCover),
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

struct MetricTile: View {
    private let title: Text
    private let systemImage: String
    private let percent: Int?
    private let caption: Text
    private let tint: Color

    init(title: Text, systemImage: String, percent: Int?, caption: Text, tint: Color) {
        self.title = title
        self.systemImage = systemImage
        self.percent = percent
        self.caption = caption
        self.tint = tint
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.tileContentSpacing) {
            Label {
                title
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScaleFactor)
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }
            .font(Typography.label)
            .textCase(.uppercase)
            .foregroundStyle(Palette.textSecondary)

            Group {
                if let percent {
                    Text(percent, format: .percent)
                } else {
                    Text(verbatim: Constants.missingValue)
                }
            }
            .font(Typography.metric)
            // Takes all the space between the top and bottom parts and centers
            // the value in it, independent of text scaling.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: Constants.tileContentSpacing) {
                caption
                    .lineLimit(1)
                    .minimumScaleFactor(Constants.minimumScaleFactor)
                    .font(Typography.footnote)
                    .foregroundStyle(Palette.textSecondary)

                ProgressView(value: Double(percent ?? 0), total: Constants.percentTotal)
                    .tint(tint)
                    .accessibilityHidden(true)
            }
        }
        .padding(Constants.cardPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

struct HourlySection: View {
    private let hours: [WeatherForecast.Hour]

    init(hours: [WeatherForecast.Hour]) {
        self.hours = hours
    }

    var body: some View {
        CardSection(title: Localizable.hourlyForecastTitle, systemImage: Constants.hourlyIcon) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: Constants.hourSpacing) {
                    ForEach(hours) { hour in
                        HourCell(hour: hour)
                    }
                }
                .padding(.horizontal, Constants.cardPadding)
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct HourCell: View {
    private let hour: WeatherForecast.Hour

    init(hour: WeatherForecast.Hour) {
        self.hour = hour
    }

    var body: some View {
        VStack(spacing: Constants.hourContentSpacing) {
            Group {
                if hour.isNow {
                    Localizable.hourlyForecastNow
                } else {
                    Text(hour.hour)
                }
            }
            .font(Typography.secondaryEmphasized)

            Image(systemName: hour.condition.symbolName(isDay: hour.isDay))
                .symbolRenderingMode(.multicolor)
                .font(Typography.largeIcon)
                .frame(height: Constants.hourIconHeight)

            Group {
                if let rainChance = hour.rainChance {
                    Text(rainChance, format: .percent)
                } else {
                    Text(verbatim: Constants.missingValue)
                }
            }
            .font(Typography.label)
            .foregroundStyle(Palette.rain)

            Text(TemperatureFormat.string(hour.temperature))
                .font(Typography.headline)
                .monospacedDigit()
        }
        .frame(minWidth: Constants.hourCellWidth)
        .accessibilityElement(children: .combine)
    }
}

struct DailySection: View {
    private let days: [WeatherForecast.Day]
    private let bounds: ClosedRange<Double>

    init(days: [WeatherForecast.Day], bounds: ClosedRange<Double>) {
        self.days = days
        self.bounds = bounds
    }

    var body: some View {
        CardSection(title: Localizable.dailyForecastTitle, systemImage: Constants.dailyIcon) {
            VStack(spacing: .zero) {
                ForEach(days) { day in
                    DayRow(day: day, bounds: bounds)
                    if day.id != days.last?.id {
                        Divider()
                            .padding(.vertical, 8.0)
                    }
                }
            }
            .padding(.horizontal, Constants.cardPadding)
        }
    }
}

struct DayRow: View {
    private let day: WeatherForecast.Day
    private let bounds: ClosedRange<Double>

    init(day: WeatherForecast.Day, bounds: ClosedRange<Double>) {
        self.day = day
        self.bounds = bounds
    }

    var body: some View {
        HStack(spacing: Constants.dayRowSpacing) {
            Group {
                if day.isToday {
                    Localizable.dailyForecastToday
                } else {
                    Text(day.weekday)
                }
            }
            .font(Typography.label)
            .lineLimit(1)
            .frame(width: Constants.weekdayWidth, alignment: .leading)

            VStack(spacing: Constants.dayIconSpacing) {
                Image(systemName: day.condition.symbolName(isDay: true))
                    .symbolRenderingMode(.multicolor)
                if let rainChance = day.rainChance {
                    Text(rainChance, format: .percent)
                        .font(Typography.smallLabel)
                        .foregroundStyle(Palette.rain)
                }
            }
            .frame(width: Constants.dayIconWidth)

            Text(TemperatureFormat.string(day.minTemperature))
                .foregroundStyle(Palette.textSecondary)
                .frame(width: Constants.temperatureWidth, alignment: .trailing)

            TemperatureRangeBar(range: day.minTemperature...day.maxTemperature, bounds: bounds)

            Text(TemperatureFormat.string(day.maxTemperature))
                .frame(width: Constants.temperatureWidth, alignment: .trailing)
        }
        .monospacedDigit()
        .frame(minHeight: Constants.dayRowHeight)
        .accessibilityElement(children: .combine)
    }
}

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

struct CardSection<Content: View>: View {
    private let title: Text
    private let systemImage: String
    private let content: Content

    init(title: Text, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.cardHeaderSpacing) {
            Label {
                title
            } icon: {
                Image(systemName: systemImage)
            }
            .font(Typography.label)
            .textCase(.uppercase)
            .foregroundStyle(Palette.textSecondary)
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, Constants.cardPadding)

            Divider()
                .padding(.horizontal, Constants.cardPadding)

            content
        }
        .padding(.vertical, Constants.cardVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.card, in: RoundedRectangle(cornerRadius: Constants.cardCornerRadius))
    }
}

struct AttributionFooter: View {
    private let updatedAt: Date?

    init(updatedAt: Date?) {
        self.updatedAt = updatedAt
    }

    var body: some View {
        VStack(spacing: Constants.footerSpacing) {
            Localizable.weatherDataAttribution
            if let updatedAt {
                Localizable.forecastUpdatedAt(updatedAt)
            }
        }
        .font(Typography.footnote)
        .foregroundStyle(Palette.textSecondary)
        .tint(Palette.accent)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct OfflineView: View {
    private let onRetry: () -> Void

    init(onRetry: @escaping () -> Void) {
        self.onRetry = onRetry
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.noInternetErrorTitle
            } icon: {
                Image(systemName: Constants.offlineIcon)
            }
        } description: {
            Localizable.noInternetErrorMessage
        } actions: {
            RetryButton(action: onRetry)
        }
    }
}

struct FailedView: View {
    private let message: String?
    private let onRetry: () -> Void

    init(message: String?, onRetry: @escaping () -> Void) {
        self.message = message
        self.onRetry = onRetry
    }

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.forecastErrorTitle
            } icon: {
                Image(systemName: Constants.failedIcon)
            }
        } description: {
            VStack(spacing: Constants.messageSpacing) {
                Localizable.forecastErrorMessage
                if let message {
                    Localizable.errorDetails(message)
                        .font(Typography.footnote)
                }
            }
        } actions: {
            RetryButton(action: onRetry)
        }
    }
}

struct RetryButton: View {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Localizable.retryButton
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(Palette.accent)
        .foregroundStyle(Palette.onAccent)
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

private enum Constants {
    static let horizontalPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 16

    static let heroTopPadding: CGFloat = 4
    static let heroSpacing: CGFloat = 4
    static let heroNameSpacing: CGFloat = 0

    static let tileSpacing: CGFloat = 12
    static let tileContentSpacing: CGFloat = 6
    static let percentTotal: Double = 100

    static let cardPadding: CGFloat = 16
    static let cardVerticalPadding: CGFloat = 12
    static let cardHeaderSpacing: CGFloat = 10
    static let cardCornerRadius: CGFloat = 14

    static let hourSpacing: CGFloat = 4
    static let hourContentSpacing: CGFloat = 6
    static let hourCellWidth: CGFloat = 48
    static let hourIconHeight: CGFloat = 28

    static let dayRowSpacing: CGFloat = 8
    static let dayRowHeight: CGFloat = 52
    static let dayIconSpacing: CGFloat = 1
    static let dayIconWidth: CGFloat = 40
    static let weekdayWidth: CGFloat = 56
    static let temperatureWidth: CGFloat = 36
    static let dailyRainThreshold = 20

    static let rangeBarHeight: CGFloat = 5
    static let minimumSpan: Double = 1

    static let footerSpacing: CGFloat = 2
    static let messageSpacing: CGFloat = 8
    static let missingValue = "–"
    
    static let minimumScaleFactor: CGFloat = 0.5

    static let cloudIcon = "cloud.fill"
    static let rainIcon = "umbrella.fill"
    static let hourlyIcon = "clock"
    static let dailyIcon = "calendar"
    static let offlineIcon = "wifi.slash"
    static let failedIcon = "exclamationmark.triangle"
}
