//
//  LinkPlatformTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import XCTest

final class LinkPlatformTests: XCTestCase {
    func test_UrlPrefix_ReturnsCorrectInstagramValue() {
        XCTAssertEqual(LinkPlatform.instagram.urlPrefix, "instagram://user?username=")
    }

    func test_UrlPrefix_ReturnsCorrectFacebookValue() {
        XCTAssertEqual(LinkPlatform.facebook.urlPrefix, "https://en-gb.facebook.com/")
    }

    // TODO: Test apple music and spotify values once they're integrated
}
