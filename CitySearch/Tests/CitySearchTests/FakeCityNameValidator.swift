//
//  FakeCityNameValidator.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation
@testable import CitySearch

struct FakeCityNameValidator: CityNameValidatorProtocol {
    let validation: CityNameValidation

    func validate(_ text: String) -> CityNameValidation {
        validation
    }
}
