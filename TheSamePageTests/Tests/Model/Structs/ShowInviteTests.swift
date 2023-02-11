//
//  ShowInviteTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/10/23.
//

@testable import TheSamePage

import XCTest

final class ShowInviteTests: XCTestCase {
    let exampleShowInvite = TestingConstants.exampleShowInviteForGenerationUnderground

    func test_AcceptanceMessage_ReturnsCorrectValue() {
        XCTAssertEqual(exampleShowInvite.acceptanceMessage, "\(exampleShowInvite.bandName) is now playing \(exampleShowInvite.showName).")
    }
}
