//
//  BandInviteTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/10/23.
//

@testable import TheSamePage

import XCTest

final class BandInviteTests: XCTestCase {
    let exampleBandInvite = TestingConstants.exampleBandInviteForTas

    func test_AcceptanceMessage_ReturnsCorrectValue() {
        XCTAssertEqual(exampleBandInvite.acceptanceMessage, "\(exampleBandInvite.recipientUsername) is now a member of \(exampleBandInvite.senderBand).")
    }
}
