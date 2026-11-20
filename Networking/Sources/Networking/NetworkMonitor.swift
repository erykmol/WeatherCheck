//
//  NetworkMonitor.swift
//  Networking
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import Network

public struct NetworkMonitor: NetworkMonitorProtocol {
    public init() {}

    public func connectivityUpdates() -> AsyncStream<Connectivity> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            let monitor = NWPathMonitor()
            let task = Task {
                for await path in monitor {
                    continuation.yield(path.status == .satisfied ? .connected : .disconnected)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
                monitor.cancel()
            }
        }
    }
}
