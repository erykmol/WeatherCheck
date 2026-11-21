//
//  NavigationStoreTests.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
@testable import Navigation

@MainActor
struct NavigationStoreTests {
    @Test func startsAtTheRootWithNothingPresented() {
        let sut = NavigationStore<TestDestination>()

        #expect(sut.path.isEmpty)
        #expect(sut.sheet == nil)
        #expect(sut.fullScreenCover == nil)
    }

    @Test func showPushesPushDestinations() {
        let sut = NavigationStore<TestDestination>()

        sut.show(.first)
        sut.show(.second)

        #expect(sut.path == [.first, .second])
        #expect(sut.sheet == nil)
        #expect(sut.fullScreenCover == nil)
    }

    @Test func showPresentsASheetOverThePath() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.first)

        sut.show(.modal)

        #expect(sut.sheet?.destination == .modal)
        #expect(sut.fullScreenCover == nil)
        #expect(sut.path == [.first])
    }

    @Test func showPresentsAFullScreenCoverOverThePath() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.first)

        sut.show(.fullScreen)

        #expect(sut.fullScreenCover?.destination == .fullScreen)
        #expect(sut.sheet == nil)
        #expect(sut.path == [.first])
    }

    @Test func aFullScreenCoverReplacesASheet() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.modal)

        sut.show(.fullScreen)

        #expect(sut.fullScreenCover?.destination == .fullScreen)
        #expect(sut.sheet == nil)
    }

    @Test func aSheetReplacesAFullScreenCover() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.fullScreen)

        sut.show(.modal)

        #expect(sut.sheet?.destination == .modal)
        #expect(sut.fullScreenCover == nil)
    }
}
