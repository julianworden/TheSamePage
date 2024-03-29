//
//  OtherUserProfileViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/13/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class OtherUserProfileViewModelTests: XCTestCase {
    var sut: OtherUserProfileViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let ericUser = TestingConstants.exampleUserEric
    let ericBandMember = TestingConstants.exampleBandMemberEric

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToJulianAccount()
    }

    override func tearDownWithError() throws {
        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInitWithUser_DefaultValuesAreAssigned() {
        sut = OtherUserProfileViewModel(user: nil, bandMember: ericBandMember)
        let predicate = NSPredicate { _,_ in
            !self.sut.shows.isEmpty
        }
        let initializerExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [initializerExpectation], timeout: 4)

        XCTAssertEqual(sut.user, ericUser)
        XCTAssertEqual(sut.firstName, ericUser.firstName)
        XCTAssertEqual(sut.lastName, ericUser.lastName)
        XCTAssertEqual(sut.emailAddress, ericUser.emailAddress)
        XCTAssertEqual(sut.profileImageUrl, ericUser.profileImageUrl)
        XCTAssertEqual(sut.bands.count, 1, "Eric is only a member of one band, Dumpweed")
        XCTAssertEqual(sut.bands.first!, TestingConstants.exampleBandDumpweed, "Eric is a member of Dumpweed")
        XCTAssertEqual(sut.shows.count, 1, "Eric's only band, Dumpweed, is only playing one show.")
        XCTAssertEqual(sut.shows.first!, TestingConstants.exampleShowDumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnInitWithBandMember_DefaultValuesAreAssigned() {
        sut = OtherUserProfileViewModel(user: nil, bandMember: ericBandMember)
        let predicate = NSPredicate { _,_ in
            !self.sut.shows.isEmpty
        }
        let initializerExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        wait(for: [initializerExpectation], timeout: 4)

        XCTAssertNotNil(sut.user)
        XCTAssertEqual(sut.user, ericUser)
        XCTAssertEqual(sut.firstName, ericUser.firstName)
        XCTAssertEqual(sut.lastName, ericUser.lastName)
        XCTAssertEqual(sut.emailAddress, ericUser.emailAddress)
        XCTAssertEqual(sut.profileImageUrl, ericUser.profileImageUrl)
        XCTAssertEqual(sut.bands.count, 1, "Eric is only a member of one band, Dumpweed")
        XCTAssertEqual(sut.bands.first!, TestingConstants.exampleBandDumpweed, "Eric is a member of Dumpweed")
        XCTAssertEqual(sut.shows.count, 1, "Eric's only band, Dumpweed, is only playing one show.")
        XCTAssertEqual(sut.shows.first!, TestingConstants.exampleShowDumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnInitWithUid_DefaultValuesAreAssigned() {
        sut = OtherUserProfileViewModel(user: nil, uid: ericUser.id)
        let predicate = NSPredicate { _,_ in
            !self.sut.shows.isEmpty
        }
        let initializerExpectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)

        wait(for: [initializerExpectation], timeout: 4)
        XCTAssertNotNil(sut.user)
        XCTAssertEqual(sut.user, ericUser)
        XCTAssertEqual(sut.firstName, ericUser.firstName)
        XCTAssertEqual(sut.lastName, ericUser.lastName)
        XCTAssertEqual(sut.emailAddress, ericUser.emailAddress)
        XCTAssertEqual(sut.profileImageUrl, ericUser.profileImageUrl)
        XCTAssertEqual(sut.bands.count, 1, "Eric is only a member of one band, Dumpweed")
        XCTAssertEqual(sut.bands.first!, TestingConstants.exampleBandDumpweed, "Eric is a member of Dumpweed")
        XCTAssertEqual(sut.shows.count, 1, "Eric's only band, Dumpweed, is only playing one show.")
        XCTAssertEqual(sut.shows.first!, TestingConstants.exampleShowDumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_OnErrorViewState_PropertiesAreChanged() {
        sut = OtherUserProfileViewModel(user: nil)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR", "The error message should be shown to the user")
        XCTAssertTrue(sut.errorAlertIsShowing, "The user should see an error alert")
    }

    func test_OnInvalidViewState_PropertiesAreChanged() {
        sut = OtherUserProfileViewModel(user: nil)

        sut.viewState = .displayingView

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState, "The error message should be shown")
        XCTAssertTrue(sut.errorAlertIsShowing, "The error alert should be shown")

    }
}
