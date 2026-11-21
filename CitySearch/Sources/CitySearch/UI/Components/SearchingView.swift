//
//  SearchingView.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct SearchingView: View {

    var body: some View {
        ProgressView {
            Localizable.searchingTitle
        }
        .tint(Palette.textSecondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, Padding.xLarge)
        .background(Palette.background)
    }
}
