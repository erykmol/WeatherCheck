//
//  TestDestination.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Navigation

enum TestDestination: NavigationDestination {
    case first, second
    case modal
    case fullScreen

    var presentation: NavigationPresentation {
        switch self {
        case .first, .second:
            .push
        case .modal:
            .sheet
        case .fullScreen:
            .fullScreenCover
        }
    }
}
