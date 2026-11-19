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
        case tooLong
        case invalid
        case valid(String)
    }

    static func validate(_ text: String) -> Result {
        let name = sanitized(text)
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

    private static func sanitized(_ text: String) -> String {
        let scalars = text.unicodeScalars
            .filter { $0.properties.generalCategory != .format }
            .map { $0.properties.generalCategory == .dashPunctuation ? Constants.hyphen : $0 }
        return String(String.UnicodeScalarView(scalars))
            .precomposedStringWithCanonicalMapping
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
    }

    private static func isAllowed(_ character: Character) -> Bool {
        character.isLetter || character == " " || character == "-"
    }
}

private enum Constants {
    static let minimumLength = 2
    static let maximumLength = 100
    static let hyphen: Unicode.Scalar = "-"
}
