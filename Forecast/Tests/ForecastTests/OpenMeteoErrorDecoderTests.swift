//
//  OpenMeteoErrorDecoderTests.swift
//  Forecast
//
//  Created by Eryk Mól on 20/11/2026.
//

import Foundation
import Testing
@testable import Forecast

struct OpenMeteoErrorDecoderTests {
    @Test func readsTheReasonFromTheErrorBody() {
        let sut = OpenMeteoErrorDecoder()

        let reason = sut.decodeReason(from: Data(#"{"error":true,"reason":"Latitude must be in range of -90 to 90°."}"#.utf8))

        #expect(reason == "Latitude must be in range of -90 to 90°.")
    }

    @Test func hasNoReasonWhenTheBodyIsNotAnErrorBody() {
        let sut = OpenMeteoErrorDecoder()

        let reason = sut.decodeReason(from: Data("<html>Bad Gateway</html>".utf8))

        #expect(reason == nil)
    }
}
