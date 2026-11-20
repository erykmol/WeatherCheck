//
//  NavigationContainer.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import SwiftUI

public struct NavigationContainer<Destination: NavigationDestinationProtocol, Root: View, Screen: View>: View {
    @Bindable private var store: NavigationStore<Destination>
    private let root: Root
    private let screen: (Destination) -> Screen

    public init(
        _ store: NavigationStore<Destination>,
        @ViewBuilder root: () -> Root,
        @ViewBuilder screen: @escaping (Destination) -> Screen
    ) {
        self.store = store
        self.root = root()
        self.screen = screen
    }

    public var body: some View {
        NavigationStack(path: $store.path) {
            root.navigationDestination(for: Destination.self, destination: screen)
        }
        .sheet(item: $store.sheet) { presented in
            screen(presented.destination)
        }
        .fullScreenCover(item: $store.fullScreenCover) { presented in
            screen(presented.destination)
        }
    }
}
