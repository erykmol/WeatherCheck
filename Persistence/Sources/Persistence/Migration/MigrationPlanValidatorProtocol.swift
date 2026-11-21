//
//  MigrationPlanValidatorProtocol.swift
//  Persistence
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation

protocol MigrationPlanValidatorProtocol {
    func validate(_ plan: any MigrationPlanProtocol.Type) throws(MigrationError)
}
