//
//  LoggedInUserControllerTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/17/23.
//

import XCTest

final class LoggedInUserControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func test_OnLeaveBand_UserLeavesBand() async throws {
//        sut = BandSettingsViewModel(band: patheticFallacy)
//
//        await sut.leaveBand()
//        let patheticFallacyWithoutJulian = try await testingDatabaseService.getBand(withId: patheticFallacy.id)
//        let patheticFallacyUpdatedBandMembers = try await testingDatabaseService.getAllBandMembers(
//            forBandWithId: patheticFallacy.id
//        )
//        let dumpweedExtravangaUpdated = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)
//        let dumpweedExtravaganzaChatUpdated = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)
//
//        XCTAssertFalse(patheticFallacyWithoutJulian.memberUids.contains(exampleUserLou.id), "Lou left PF")
//        XCTAssertFalse (patheticFallacyUpdatedBandMembers.contains(exampleBandMemberLou), "Lou left PF")
//        XCTAssertFalse(dumpweedExtravaganzaChatUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be in any chats for shows that PF is playing")
//        XCTAssertFalse(dumpweedExtravangaUpdated.participantUids.contains(exampleUserLou.id), "Lou should no longer be a participant in any shows that PF is playing")
//
//        try await testingDatabaseService.restorePatheticFallacy(
//            band: patheticFallacy,
//            show: dumpweedExtravaganza,
//            chat: TestingConstants.exampleChatDumpweedExtravaganza,
//            bandMember: exampleBandMemberLou
//        )
//    }
}
