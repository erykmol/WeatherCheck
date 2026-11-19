//
//  CityNameValidatorTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
@testable import CitySearch

struct CityNameValidatorTests {
    @Test(arguments: ["Łódź", "Bielsko-Biała", "Nowy Sącz", "Gdańsk"])
    func acceptsLettersSpacesAndHyphens(name: String) {
        #expect(CityNameValidator.validate(name) == .valid(name))
    }

    @Test func trimsSurroundingSpaces() {
        #expect(CityNameValidator.validate("  Kraków ") == .valid("Kraków"))
    }

    @Test(arguments: ["Kraków1", "Gdańsk!", "Łódź?", "1"])
    func rejectsOtherCharacters(name: String) {
        #expect(CityNameValidator.validate(name) == .invalid)
    }

    @Test func treatsBlankTextAsEmpty() {
        #expect(CityNameValidator.validate("   ") == .empty)
    }

    @Test func needsAtLeastTwoLetters() {
        #expect(CityNameValidator.validate("Ł") == .tooShort)
    }
}
