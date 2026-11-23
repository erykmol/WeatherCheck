//
//  Typography.swift
//  DesignSystem
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI

public enum Typography {
    public static let displaySize: CGFloat = 88.0

    public static let metric = Font.largeTitle.weight(.semibold)
    public static let title = Font.title.weight(.semibold)
    public static let prominent = Font.title3.weight(.medium)
    public static let headline = Font.headline
    public static let bodyEmphasized = Font.body.weight(.medium)
    public static let secondary = Font.subheadline
    public static let secondaryEmphasized = Font.subheadline.weight(.semibold)
    public static let footnote = Font.footnote
    public static let label = Font.caption.weight(.semibold)
    public static let smallLabel = Font.caption2.weight(.semibold)

    public static let icon = Font.title3
    public static let largeIcon = Font.title2
    public static let accessory = Font.footnote.weight(.semibold)
    
    public static func makeDisplayFont(size: CGFloat) -> Font {
        .system(size: size, weight: .thin)
    }
}
