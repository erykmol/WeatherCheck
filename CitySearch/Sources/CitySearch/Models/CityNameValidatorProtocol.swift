//
//  CityNameValidatorProtocol.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

protocol CityNameValidatorProtocol {
    func validate(_ text: String) -> CityNameValidation
}
