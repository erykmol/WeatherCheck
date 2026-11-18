//
//  NavigationStoreTests.swift
//  Navigation
//
//  Created by Eryk Mól on 18/11/2026.
//

import Foundation
import Testing
import Navigation

@MainActor
struct NavigationStoreTests {
    @Test func startsAtTheRootWithNothingPresented() {
        let sut = NavigationStore<TestDestination>()
        #expect(sut.path.isEmpty)
        #expect(sut.presented == nil)
    }

    @Test func showPushesPushDestinations() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.first)
        sut.show(.second)
        #expect(sut.path == [.first, .second])
        #expect(sut.presented == nil)
    }

    @Test(arguments: [TestDestination.modal, .fullScreen])
    func showPresentsModalDestinationsOverThePath(destination: TestDestination) {
        let sut = NavigationStore(path: [TestDestination.first])
        sut.show(destination)
        #expect(sut.presented == destination)
        #expect(sut.path == [.first])
    }

    @Test func aModalReplacesTheOneOnScreen() {
        let sut = NavigationStore<TestDestination>()
        sut.show(.modal)
        sut.show(.fullScreen)
        #expect(sut.presented == .fullScreen)
    }

    @Test func dismissClosesTheModalAndKeepsThePath() {
        let sut = NavigationStore(path: [TestDestination.first])
        sut.show(.modal)
        sut.dismiss()
        #expect(sut.presented == nil)
        #expect(sut.path == [.first])
    }

    @Test func popRemovesTheTopScreen() {
        let sut = NavigationStore(path: [TestDestination.first, .second])
        sut.pop()
        #expect(sut.path == [.first])
    }

    @Test func popAtTheRootDoesNothing() {
        let sut = NavigationStore<TestDestination>()
        sut.pop()
        #expect(sut.path.isEmpty)
    }

    @Test func popToRootClearsThePath() {
        let sut = NavigationStore(path: [TestDestination.first, .second])
        sut.popToRoot()
        #expect(sut.path.isEmpty)
    }
}
