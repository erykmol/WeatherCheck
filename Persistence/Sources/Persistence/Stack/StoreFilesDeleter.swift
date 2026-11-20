//
//  StoreFilesDeleter.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

public struct StoreFilesDeleter: StoreFilesDeleterProtocol {
    public init() {}

    public func deleteStoreFiles(at url: URL) throws {
        for suffix in Constants.storeFileSuffixes {
            let file = URL(filePath: url.path(percentEncoded: false) + suffix)
            if FileManager.default.fileExists(atPath: file.path(percentEncoded: false)) {
                try FileManager.default.removeItem(at: file)
            }
        }
    }
}

private enum Constants {
    static let storeFileSuffixes = ["", "-wal", "-shm"]
}
