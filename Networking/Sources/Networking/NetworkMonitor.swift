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
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied ? .connected : .disconnected)
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: Constants.queueLabel))
        }
    }
}

private enum Constants {
    static let queueLabel = "Networking.NetworkMonitor"
}
