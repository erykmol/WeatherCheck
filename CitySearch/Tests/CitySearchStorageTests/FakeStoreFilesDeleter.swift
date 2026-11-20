//
//  FakeStoreFilesDeleter.swift
//  CitySearchStorage
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Persistence

final class FakeStoreFilesDeleter: StoreFilesDeleterProtocol {
    private(set) var deletedURLs: [URL] = []

    func deleteStoreFiles(at url: URL) {
        deletedURLs.append(url)
    }
}
