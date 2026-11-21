//
//  OpenMeteoErrorDecoderTests.swift
//  CitySearch
//
//  Created by Eryk Mól on 21/11/2026.
//

import Foundation
import Testing
@testable import CitySearch

struct OpenMeteoErrorDecoderTests {
    @Test func readsTheReasonFromTheErrorBody() {
        let sut = OpenMeteoErrorDecoder()

        let reason = sut.reason(from: Data(#"{"error":true,"reason":"Parameter count must be between 1 and 100."}"#.utf8))

        #expect(reason == "Parameter count must be between 1 and 100.")
    }

    @Test func hasNoReasonWhenTheBodyIsNotAnErrorBody() {
        let sut = OpenMeteoErrorDecoder()

        let reason = sut.reason(from: Data("<html>Bad Gateway</html>".utf8))

        #expect(reason == nil)
    }
}
