//
//  CoreDataStack+Close.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import CoreData
import Persistence

extension CoreDataStack {
    public func close() throws {
        viewContext.reset()
        guard let coordinator = viewContext.persistentStoreCoordinator else { return }
        for store in coordinator.persistentStores {
            try coordinator.remove(store)
        }
    }
}
