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
public final class NavigationStore<Destination: Hashable> {
    
    public var path: [Destination]

    public init(path: [Destination] = []) {
        self.path = path
    }

    public func push(_ destination: Destination) {
        path.append(destination)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }
}
