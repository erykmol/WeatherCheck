//
//  NavigationDestination.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

public protocol NavigationDestination: Hashable {
    var presentation: NavigationPresentation { get }
}
