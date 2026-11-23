//
//  StubNetworkMonitor.swift
//  Networking
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Networking

public struct StubNetworkMonitor: NetworkMonitorProtocol {
    private let updates: [Connectivity]

    public init(updates: [Connectivity]) {
        self.updates = updates
    }

    public func monitorConnectivity() -> AsyncStream<Connectivity> {
        AsyncStream { continuation in
            for update in updates {
                continuation.yield(update)
            }
            continuation.finish()
        }
    }
}
