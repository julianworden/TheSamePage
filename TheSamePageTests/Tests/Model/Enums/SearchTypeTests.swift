//
//  SearchTypeTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/8/23.
//

@testable import TheSamePage

import XCTest

final class SearchTypeTests: XCTestCase {
    func test_FirestoreCollection_UserSearchReturnsCorrectValue() {
        XCTAssertEqual(SearchType.user.firestoreCollection, "users")
    }

    func test_FirestoreCollection_BandSearchReturnsCorrectValue() {
        XCTAssertEqual(SearchType.band.firestoreCollection, "bands")
    }

    func test_FirestoreCollection_ShowSearchReturnsCorrectValue() {
        XCTAssertEqual(SearchType.show.firestoreCollection, "shows")
    }
}
