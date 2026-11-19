//
//  CityNameValidator.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

enum CityNameValidator {
    enum Result: Equatable {
        case empty
        case tooShort
        case invalid
        case valid(String)
    }

    static let minimumLength = 2

    static func validate(_ text: String) -> Result {
        let name = text.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return .empty }
        guard name.allSatisfy(isAllowed) else { return .invalid }
        guard name.count >= minimumLength else { return .tooShort }
        return .valid(name)
    }

    private static func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}
