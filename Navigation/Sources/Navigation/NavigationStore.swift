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
public final class NavigationStore<Destination: NavigationDestination> {

    public var path: [Destination]

    public var presented: Destination? {
        sheet?.destination ?? fullScreenCover?.destination
    }

    var sheet: PresentedDestination<Destination>?
    var fullScreenCover: PresentedDestination<Destination>?

    public init(path: [Destination] = []) {
        self.path = path
    }

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

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }
}
