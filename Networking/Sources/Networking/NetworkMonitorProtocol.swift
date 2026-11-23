//
//  NetworkMonitorProtocol.swift
//  Networking
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

public protocol NetworkMonitorProtocol: Sendable {
    func monitorConnectivity() -> AsyncStream<Connectivity>
}
