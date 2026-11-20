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
        let sut = CityNameValidator()

        #expect(sut.validate(name) == .valid(name))
    }

    @Test func trimsSurroundingSpaces() {
        let sut = CityNameValidator()

        #expect(sut.validate("  Kraków ") == .valid("Kraków"))
    }

    @Test(arguments: ["Kraków1", "Gdańsk!", "Łódź?", "1", "Łódź🙂", "'; DROP TABLE cities; --"])
    func rejectsOtherCharacters(name: String) {
        let sut = CityNameValidator()

        #expect(sut.validate(name) == .invalid)
    }

    @Test(arguments: [
        ("Łódź\n", "Łódź"),
        ("Nowy\u{00A0}Sącz", "Nowy Sącz"),
        ("Nowy   Sącz", "Nowy Sącz"),
        ("Kra\u{200B}ków", "Kraków"),
        ("Bielsko\u{2013}Biała", "Bielsko-Biała"),
    ])
    func cleansUpPastedText(text: String, name: String) {
        let sut = CityNameValidator()

        #expect(sut.validate(text) == .valid(name))
    }

    @Test func composesDecomposedLetters() {
        let sut = CityNameValidator()

        let result = sut.validate("\u{0141}o\u{0301}dz\u{0301}")

        guard case .valid(let name) = result else {
            Issue.record("Expected a valid name, got \(result)")
            return
        }
        #expect(Array(name.unicodeScalars) == Array("\u{0141}\u{00F3}d\u{017A}".unicodeScalars))
    }

    @Test func acceptsANameOfOneHundredCharacters() {
        let sut = CityNameValidator()
        let name = String(repeating: "a", count: 100)

        #expect(sut.validate(name) == .valid(name))
    }

    @Test func rejectsANameLongerThanOneHundredCharacters() {
        let sut = CityNameValidator()

        #expect(sut.validate(String(repeating: "a", count: 101)) == .tooLong)
    }

    @Test func treatsBlankTextAsEmpty() {
        let sut = CityNameValidator()

        #expect(sut.validate("   ") == .empty)
    }

    @Test func needsAtLeastTwoLetters() {
        let sut = CityNameValidator()

        #expect(sut.validate("Ł") == .tooShort)
    }
}
