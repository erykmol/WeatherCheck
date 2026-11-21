//
//  TestItem.swift
//  Persistence
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
import CoreData

public struct TestItem: Equatable {
    public let title: String
    public let note: String?
    public let amount: Double
    public let unit: String

    public init(title: String, note: String?, amount: Double, unit: String) {
        self.title = title
        self.note = note
        self.amount = amount
        self.unit = unit
    }
}

extension TestItem {
    public init(_ object: NSManagedObject) {
        self.init(
            title: object.value(forKey: "title") as? String ?? "",
            note: object.value(forKey: "note") as? String,
            amount: object.value(forKey: "amount") as? Double ?? .nan,
            unit: object.value(forKey: "unit") as? String ?? ""
        )
    }
}
