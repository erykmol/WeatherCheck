import OSLog
import Foundation

private let subsystem = Bundle.main.bundleIdentifier ?? "WeatherCheck"

package let logger = Logger(subsystem: subsystem, category: "Forecast")
