//
//  VersionedSchemaProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public protocol VersionedSchemaProtocol {
    static var versionIdentifier: String { get }

    static var versionChecksum: String { get }

    static func makeEntities() -> [NSEntityDescription]
}
