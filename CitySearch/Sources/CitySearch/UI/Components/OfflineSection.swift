//
//  OfflineSection.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI
import DesignSystem

struct OfflineSection: View {
    var body: some View {
        Section {
            OfflineBanner()
        }
        .listRowBackground(Palette.warningBackground)
    }
}
