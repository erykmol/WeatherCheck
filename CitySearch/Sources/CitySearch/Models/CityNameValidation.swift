//
//  CityNameValidation.swift
//  CitySearch
//
//  Created by Eryk Mól on 19/11/2026.
//

import Foundation

enum CityNameValidation: Equatable {
    case empty
    case tooShort
    case tooLong
    case invalid
    case valid(String)
}
