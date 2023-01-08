//
//  PlatformLinkTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import XCTest

final class PlatformLinkTests: XCTestCase {
    var testingDatabaseService: TestingDatabaseService!

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        testingDatabaseService = nil
    }

    func test_PlatformNameAsPlatformLinkObject_InstagramStringReturnsInstagramObject() {
        let link = TestingConstants.examplePlatformLinkPatheticFallacyInstagram

        XCTAssertEqual(LinkPlatform.instagram, link.platformNameAsPlatformLinkObject)
    }

    func test_PlatformNameAsPlatformLinkObject_FacebookStringReturnsFacebookObject() {
        let link = TestingConstants.examplePlatformLinkPatheticFallacyFacebook

        XCTAssertEqual(LinkPlatform.facebook, link.platformNameAsPlatformLinkObject)
    }

    // TODO: Make and test spotify link once that functionality is working
}
