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
    public static let track = loadColor(named: "Track")

    public static let textPrimary = Color(uiColor: .label)
    public static let textSecondary = loadColor(named: "TextSecondary")

    public static let accent = loadColor(named: "Accent")
    public static let onAccent = loadColor(named: "OnAccent")
    public static let rain = loadColor(named: "Rain")
    public static let cloud = loadColor(named: "Cloud")
    public static let sun = loadColor(named: "Sun")
    public static let warning = loadColor(named: "Warning")
    public static let warningBackground = loadColor(named: "WarningBackground")
    public static let destructive = loadColor(named: "Destructive")

    public static let lightGray = loadColor(named: "LightGray")
    
    private static func loadColor(named name: String) -> Color {
        Color(name, bundle: .module)
    }
}
