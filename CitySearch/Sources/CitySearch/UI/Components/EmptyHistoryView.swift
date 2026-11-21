//
//  EmptyHistoryView.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import SwiftUI

struct EmptyHistoryView: View {

    var body: some View {
        ContentUnavailableView {
            Label {
                Localizable.emptyHistoryTitle
            } icon: {
                Image(systemName: Constants.emptyIcon)
            }
        } description: {
            Localizable.emptyHistoryMessage
        }
    }
}

private enum Constants {
    static let emptyIcon = "mappin.and.ellipse"
}
