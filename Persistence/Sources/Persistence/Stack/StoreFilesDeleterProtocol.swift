//
//  StoreFilesDeleterProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

public protocol StoreFilesDeleterProtocol {
    func deleteStoreFiles(at url: URL) throws
}
