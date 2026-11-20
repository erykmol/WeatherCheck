//
//  CoreDataStackFactoryProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

@MainActor
public protocol CoreDataStackFactoryProtocol {
    associatedtype Stack

    func makeStack(storage: CoreDataStack.Storage) throws -> Stack

    func deleteStoreFiles(at url: URL) throws
}
