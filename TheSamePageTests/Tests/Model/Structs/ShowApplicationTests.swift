//
//  ShowApplicationTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 2/10/23.
//

@testable import TheSamePage

import XCTest

final class ShowApplicationTests: XCTestCase {
    let exampleShowApplication = TestingConstants.exampleShowApplicationForDumpweedExtravaganza

    func test_AcceptanceMessage_ReturnsCorrectValue() {
        XCTAssertEqual(exampleShowApplication.acceptanceMessage, "\(exampleShowApplication.bandName) is now playing \(exampleShowApplication.showName).")
    }
}
