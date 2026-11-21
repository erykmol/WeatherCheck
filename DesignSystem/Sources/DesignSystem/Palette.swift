//
//  Palette.swift
//  DesignSystem
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI
import UIKit

public enum Palette {
    public static let background = Color(uiColor: .systemGroupedBackground)
    public static let card = Color(uiColor: .secondarySystemGroupedBackground)
    public static let separator = Color(uiColor: .separator)
    public static let track = catalog("Track")

    public static let textPrimary = Color(uiColor: .label)
    public static let textSecondary = catalog("TextSecondary")

    public static let accent = catalog("Accent")
    public static let onAccent = catalog("OnAccent")
    public static let rain = catalog("Rain")
    public static let cloud = catalog("Cloud")
    public static let sun = catalog("Sun")
    public static let warning = catalog("Warning")
    public static let warningBackground = catalog("WarningBackground")
    public static let destructive = catalog("Destructive")

    public static let lightGray = catalog("LightGray")
    
    private static func catalog(_ name: String) -> Color {
        Color(name, bundle: .module)
    }
}
