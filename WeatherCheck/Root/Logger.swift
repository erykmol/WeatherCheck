//
//  Logger.swift
//  WeatherCheck
//
//  Created by Eryk Mól on 18/11/2026.
//

import OSLog
import Foundation

private let subsystem = Bundle.main.bundleIdentifier ?? "WeatherCheck"

let logger = Logger(subsystem: subsystem, category: "Main")
