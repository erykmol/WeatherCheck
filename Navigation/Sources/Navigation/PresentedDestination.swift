//
//  PresentedDestination.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct PresentedDestination<Destination: Hashable>: Identifiable {
    let destination: Destination

    var id: Destination {
        destination
    }
}
