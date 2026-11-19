//
//  URL+Extensions.swift
//  Networking
//
//  Created by Eryk Mól on 17/11/2026.
//

import Foundation

public extension URL {
    init(staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            fatalError("Invalid URL String: \(staticString)")
        }
        self = url
    }
}
