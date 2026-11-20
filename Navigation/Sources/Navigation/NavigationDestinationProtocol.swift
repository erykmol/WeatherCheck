//
//  NavigationDestinationProtocol.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

public protocol NavigationDestinationProtocol: Hashable {
    var presentation: NavigationPresentation { get }
}
