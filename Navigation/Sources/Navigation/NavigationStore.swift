//
//  NavigationStore.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Observation

@MainActor
@Observable
public final class NavigationStore<Destination: NavigationDestinationProtocol> {

    public var path: [Destination] = []

    var sheet: PresentedDestination<Destination>?
    var fullScreenCover: PresentedDestination<Destination>?

    public init() {}

    public func show(_ destination: Destination) {
        switch destination.presentation {
        case .push:
            path.append(destination)
        case .sheet:
            fullScreenCover = nil
            sheet = PresentedDestination(destination: destination)
        case .fullScreenCover:
            sheet = nil
            fullScreenCover = PresentedDestination(destination: destination)
        }
    }
}
