//
//  TestItem.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

struct TestItem: Equatable {
    let title: String
    let note: String?
    let amount: Double
    let unit: String
}

extension TestItem {
    init(_ object: NSManagedObject) {
        self.init(
            title: object.value(forKey: "title") as? String ?? "",
            note: object.value(forKey: "note") as? String,
            amount: object.value(forKey: "amount") as? Double ?? .nan,
            unit: object.value(forKey: "unit") as? String ?? ""
        )
    }
}
