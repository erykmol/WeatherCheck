//
//  FakeMigrationPlanValidator.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
@testable import Persistence

final class FakeMigrationPlanValidator: MigrationPlanValidatorProtocol {
    private let error: MigrationError?
    private(set) var validatedPlans: [ObjectIdentifier] = []

    init(error: MigrationError? = nil) {
        self.error = error
    }

    func validate(_ plan: any MigrationPlanProtocol.Type) throws(MigrationError) {
        validatedPlans.append(ObjectIdentifier(plan))
        if let error {
            throw error
        }
    }
}
