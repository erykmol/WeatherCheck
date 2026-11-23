//
//  CityNameValidator.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation

struct CityNameValidator: CityNameValidatorProtocol {
    func validate(_ text: String) -> CityNameValidation {
        let name = sanitize(text)
        guard !name.isEmpty else {
            return .empty
        }
        guard name.allSatisfy(isAllowed) else {
            return .invalid
        }
        guard name.count >= Constants.minimumLength else {
            return .tooShort
        }
        guard name.count <= Constants.maximumLength else {
            return .tooLong
        }
        return .valid(name)
    }

    private func sanitize(_ text: String) -> String {
        let scalars = text.unicodeScalars
            .filter { $0.properties.generalCategory != .format }
            .map { $0.properties.generalCategory == .dashPunctuation ? Constants.hyphen : $0 }
        return String(String.UnicodeScalarView(scalars))
            .precomposedStringWithCanonicalMapping
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}

private enum Constants {
    static let minimumLength = 2
    static let maximumLength = 100
    static let hyphen: Unicode.Scalar = "-"
}
