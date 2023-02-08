//
//  ShowDetailsViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/16/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class ShowDetailsViewModelTests: XCTestCase {
    var sut: ShowDetailsViewModel!
    var testingDatabaseService: TestingDatabaseService!
    var createdShowId: String?
    let craigAndTheFettuccinis = TestingConstants.exampleBandCraigAndTheFettuccinis
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let showParticipantDumpweed = TestingConstants.exampleShowParticipantDumpweedInDumpweedExtravaganza
    let showParticipantPatheticFallacy = TestingConstants.exampleShowParticipantPatheticFallacyInDumpweedExtravaganza

    override func setUpWithError() throws {
        testingDatabaseService = TestingDatabaseService()
    }

    override func tearDown() async throws {
        if let createdShowId {
            try await testingDatabaseService.deleteShow(withId: createdShowId)
            self.createdShowId = nil
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.selectedTab, .details)
        XCTAssertTrue(sut.showBackline.isEmpty)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertFalse(sut.editImageViewIsShowing)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertFalse(sut.addBacklineSheetIsShowing)
        XCTAssertFalse(sut.bandSearchViewIsShowing)
    }

    func test_OnErrorViewState_PropertiesAreChanged() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        sut.viewState = .error(message: "TEST ERROR")

        XCTAssertEqual(sut.errorAlertText, "TEST ERROR")
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnInvalidViewState_PropertiesAreChanged() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        sut.viewState = .dataLoading

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnCallOnAppearMethods_PropertiesAreSet() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.callOnAppearMethods()

        XCTAssertEqual(sut.showBackline.count, 5)
        XCTAssertEqual(sut.showParticipants.count, 2, "Two bands are playing this show")
        XCTAssertEqual(sut.viewState, .dataLoaded)
    }

    func test_ShowSlotsRemainingMessage_ReturnsCorrectValueWhenShowLineupHasMoreThanOneSlotRemaining() async throws {
        var dumpweedExtravaganzaCopy = dumpweedExtravaganza
        dumpweedExtravaganzaCopy.maxNumberOfBands = 5
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganzaCopy)
        await sut.getShowParticipants()

        XCTAssertEqual(sut.showSlotsRemainingMessage, "3 slots remaining", "There should be 3 slots remaining since the max number of bands is 5 and there are 2 bands playing")
    }

    func test_ShowSlotsRemainingMessage_ReturnsCorrectValueWhenShowLineupHasOneSlotRemaining() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        await sut.callOnAppearMethods()

        XCTAssertEqual(sut.showSlotsRemainingMessage, "1 slot remaining", "There should be 1 slot remaining since the max number of bands is 3 and there are 2 bands playing")
    }

    func test_NoShowTimesMessage_ReturnsCorrectValueWhenLoggedInUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowTimesMessage, "No times have been added to this show. Use the buttons above to add show times.")
    }

    func test_NoShowTimesMessage_ReturnsCorrectValueWhenLoggedInUserIsNotShowHost() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowTimesMessage, "No times have been added to this show. Only the show's host can add times.")
    }

    func test_ShowHasBackline_ReturnsTrueWhenShowHasBackline() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        await sut.getBacklineItems()

        XCTAssertTrue(sut.showHasBackline)
    }

    func test_ShowHasBackline_ReturnsFalseWithNoBacklineItems() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertFalse(sut.showHasBackline)
    }

    func test_NoShowParticipantsText_ReturnsCorrectValueWhenLoggedInUserIsShowHost() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowParticipantsText, "No bands are playing this show.")
    }

    func test_NoShowParticipantsText_ReturnsCorrectValueWhenLoggedInUserIsNotInvolvedWithShow() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noShowParticipantsText, "No bands are playing this show yet. Only the show's host can invite bands to play.")
    }

    func test_NoBacklineMessageText_ReturnsCorrectValueWhenLoggedInUserIsShowParticipant() async throws {
        try await testingDatabaseService.logInToLouAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noBacklineMessageText, "This show has no backline.", "Lou is a show participant")
    }

    func test_NoBacklineMessageText_ReturnsCorrectValueWhenLoggedInUserIsNotShowParticipant() async throws {
        try await testingDatabaseService.logInToMikeAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertEqual(sut.noBacklineMessageText, "This show has no backline. You must be participating in this show to add backline to it.", "Mike is not a participant in this show")
    }

    func test_MapAnnotations_ReturnCorrectValue() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        let customMapAnnotation = CustomMapAnnotation(coordinates: dumpweedExtravaganza.coordinates)

        XCTAssertEqual(sut.mapAnnotations.count, 1, "We only need one map annotation for the show")
        XCTAssertEqual(sut.mapAnnotations.first!.coordinate.latitude, customMapAnnotation.coordinate.latitude)
        XCTAssertEqual(sut.mapAnnotations.first!.coordinate.longitude, customMapAnnotation.coordinate.longitude)
    }

    func test_OnTimeForShowExistsWithAllNonNilTimes_ReturnsTrue() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        XCTAssertTrue(sut.timeForShowExists(showTimeType: .loadIn), "Dumpweed Extravaganza has a load in time")
        XCTAssertTrue(sut.timeForShowExists(showTimeType: .doors), "Dumpweed Extravaganza has a doors time")
        XCTAssertTrue(sut.timeForShowExists(showTimeType: .musicStart), "Dumpweed Extravaganza has a music start time")
        XCTAssertTrue(sut.timeForShowExists(showTimeType: .end), "Dumpweed Extravaganza has an end time")
    }

    func test_OnTimeForShowExistsWithAllNilTimes_ReturnsTrue() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.doorsTime = nil
        dumpweedExtravaganzaDup.loadInTime = nil
        dumpweedExtravaganzaDup.musicStartTime = nil
        dumpweedExtravaganzaDup.endTime = nil
        sut = ShowDetailsViewModel(show: dumpweedExtravaganzaDup)

        XCTAssertFalse(sut.timeForShowExists(showTimeType: .loadIn), "Dumpweed Extravaganza has no load in time")
        XCTAssertFalse(sut.timeForShowExists(showTimeType: .doors), "Dumpweed Extravaganza has no doors time")
        XCTAssertFalse(sut.timeForShowExists(showTimeType: .musicStart), "Dumpweed Extravaganza has no music start time")
        XCTAssertFalse(sut.timeForShowExists(showTimeType: .end), "Dumpweed Extravaganza has no end time")
    }

    func test_OnGetLatestShowData_UpdatedShowDataIsFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        try await testingDatabaseService.updateShowName(showId: dumpweedExtravaganza.id, newName: "Heavy Banger")

        await sut.getLatestShowData()

        XCTAssertEqual(sut.show.name, "Heavy Banger")

        try await testingDatabaseService.updateShowName(showId: dumpweedExtravaganza.id, newName: dumpweedExtravaganza.name)
    }

    func test_OnGetShowParticipants_ShowParticipantsAreFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.getShowParticipants()

        XCTAssertEqual(sut.showParticipants.count, 2, "Dumpweed and Pathetic Fallacy are playing this show")
        XCTAssertTrue(sut.showParticipants.contains(showParticipantDumpweed), "Dumpweed is playing this show")
        XCTAssertTrue(sut.showParticipants.contains(showParticipantPatheticFallacy), "Pathetic Fallacy is playing this show")
    }

    func test_OnRemoveShowParticipantFromShow_ShowParticipantIsRemovedFromShow() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        var craigAndTheFettuccinisAsShowParticipant = ShowParticipant(
            name: craigAndTheFettuccinis.name,
            bandId: craigAndTheFettuccinis.id,
            bandAdminUid: craigAndTheFettuccinis.adminUid,
            showId: dumpweedExtravaganza.id
        )
        let showParticipantDocumentId = try await testingDatabaseService.addBandToShow(
            add: craigAndTheFettuccinis,
            as: craigAndTheFettuccinisAsShowParticipant,
            to: dumpweedExtravaganza
        )
        craigAndTheFettuccinisAsShowParticipant.id = showParticipantDocumentId
        let showParticipant = try await testingDatabaseService.getShowParticipant(craigAndTheFettuccinisAsShowParticipant)

        await sut.removeShowParticipantFromShow(showParticipant: showParticipant)
        let editedShow = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)
        let editedShowChat = try await testingDatabaseService.getChat(forShowWithId: dumpweedExtravaganza.id)

        do {
            _ = try await testingDatabaseService.getShowParticipant(craigAndTheFettuccinisAsShowParticipant)
            XCTFail("The show participant should've been deleted, so the fetch shouldn't have been successful")
        } catch {
            XCTAssertNotNil(error)
            XCTAssertEqual(editedShow.bandIds.count, 2, "There should only be 2 bands on the show now")
            XCTAssertEqual(editedShow.participantUids.count, 3, "There should only be 3 users in the array")
            XCTAssertFalse(editedShow.participantUids.contains(TestingConstants.exampleUserCraig.id))
            XCTAssertFalse(editedShowChat.participantUids.contains(TestingConstants.exampleUserCraig.id))
        }
    }

    func test_OnGetBacklineItems_BacklineItemsAreFetched() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.getBacklineItems()

        XCTAssertEqual(sut.showBackline.count, 5)
    }

    func test_OnDeleteShowImage_ImageIsDeleted() async throws {
        try await testingDatabaseService.logInToEricAccount()
        var exampleShow = TestingConstants.exampleShowForIntegrationTesting
        self.createdShowId = try await testingDatabaseService.createShowWithImage(exampleShow)
        exampleShow.id = createdShowId!
        let createdShowWithOldProfileImageUrl = try await testingDatabaseService.getShow(withId: exampleShow.id)
        exampleShow.imageUrl = createdShowWithOldProfileImageUrl.imageUrl
        sut = ShowDetailsViewModel(show: exampleShow)

        await sut.deleteShowImage()
        let createdShowWithNoProfileImage = try await testingDatabaseService.getShow(withId: exampleShow.id)

        do {
            _ = try await testingDatabaseService.imageExists(at: exampleShow.imageUrl!)
            XCTFail("The image shouldn't exist, so this method should've thrown an error")
        } catch {
            XCTAssertNotNil(error, "An error should've been thrown")
        }

        XCTAssertNil(createdShowWithNoProfileImage.imageUrl, "The show should no longer have a imageUrl property")
    }

    func test_OnRemoveShowTimeFromShow_ShowTimesAreRemovedFromShow() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.removeShowTimeFromShow(showTimeType: .loadIn)
        await sut.removeShowTimeFromShow(showTimeType: .doors)
        await sut.removeShowTimeFromShow(showTimeType: .musicStart)
        await sut.removeShowTimeFromShow(showTimeType: .end)
        let updatedDumpweedExtravaganza = try await testingDatabaseService.getShow(withId: dumpweedExtravaganza.id)

        XCTAssertNil(updatedDumpweedExtravaganza.loadInTime)
        XCTAssertNil(updatedDumpweedExtravaganza.doorsTime)
        XCTAssertNil(updatedDumpweedExtravaganza.musicStartTime)
        XCTAssertNil(updatedDumpweedExtravaganza.endTime)
        XCTAssertNil(sut.show.loadInTime)
        XCTAssertNil(sut.show.doorsTime)
        XCTAssertNil(sut.show.musicStartTime)
        XCTAssertNil(sut.show.endTime)

        try testingDatabaseService.restoreExampleShowData(withDataIn: dumpweedExtravaganza)
    }

    func test_OnGetShowTimeRowTextForNonNilShowTimes_CorrectValuesAreReturned() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        let doorsText = sut.getShowTimeRowText(forShowTimeType: .doors)
        let loadInText = sut.getShowTimeRowText(forShowTimeType: .loadIn)
        let musicStartText = sut.getShowTimeRowText(forShowTimeType: .musicStart)
        let endText = sut.getShowTimeRowText(forShowTimeType: .end)

        XCTAssertEqual("\(ShowTimeType.doors.rowTitleText) \(dumpweedExtravaganza.doorsTime!.unixDateAsDate.timeShortened)", doorsText)
        XCTAssertEqual("\(ShowTimeType.loadIn.rowTitleText) \(dumpweedExtravaganza.loadInTime!.unixDateAsDate.timeShortened)", loadInText)
        XCTAssertEqual("\(ShowTimeType.musicStart.rowTitleText) \(dumpweedExtravaganza.musicStartTime!.unixDateAsDate.timeShortened)", musicStartText)
        XCTAssertEqual("\(ShowTimeType.end.rowTitleText) \(dumpweedExtravaganza.endTime!.unixDateAsDate.timeShortened)", endText)
    }

    func test_OnGetShowTimeRowTextForNilShowTimes_CorrectValuesAreReturned() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        var dumpweedExtravaganzaDup = dumpweedExtravaganza
        dumpweedExtravaganzaDup.doorsTime = nil
        dumpweedExtravaganzaDup.loadInTime = nil
        dumpweedExtravaganzaDup.musicStartTime = nil
        dumpweedExtravaganzaDup.endTime = nil
        sut = ShowDetailsViewModel(show: dumpweedExtravaganzaDup)

        let doorsText = sut.getShowTimeRowText(forShowTimeType: .doors)
        let loadInText = sut.getShowTimeRowText(forShowTimeType: .loadIn)
        let musicStartText = sut.getShowTimeRowText(forShowTimeType: .musicStart)
        let endText = sut.getShowTimeRowText(forShowTimeType: .end)

        XCTAssertEqual("Doors: Not Set", doorsText)
        XCTAssertEqual("Load In: Not Set", loadInText)
        XCTAssertEqual("Music Start: Not Set", musicStartText)
        XCTAssertEqual("End: Not Set", endText)
    }

    func test_OnClearAllBacklineItems_BacklineArrayIsCleared() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)
        await sut.getBacklineItems()

        sut.clearAllBackline()

        XCTAssertTrue(sut.showBackline.isEmpty)
    }

    func test_OnDeleteBackline_BacklineItemIsDeleted() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.deleteBackline(TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza)

        do {
            _ = try await testingDatabaseService.getBacklineItem(
                withId: TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza.id!,
                inShowWithId: dumpweedExtravaganza.id
            )
            XCTFail("This fetch should've failed because the BacklineItem was deleted")
        } catch Swift.DecodingError.valueNotFound {
            XCTAssert(true)
        } catch {
            XCTFail("The only error that should be thrown here is a Swift.DecodingError.valueNotFound.")
        }

        try await testingDatabaseService.createBacklineItem(
            create: TestingConstants.exampleBassGuitarBacklineItemDumpweedExtravaganza,
            in: dumpweedExtravaganza
        )
    }

    func test_OnDeleteBackline_DrumKitBacklineItemIsDeleted() async throws {
        try await testingDatabaseService.logInToJulianAccount()
        sut = ShowDetailsViewModel(show: dumpweedExtravaganza)

        await sut.deleteBackline(TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza)

        do {
            _ = try await testingDatabaseService.getDrumKitBacklineItem(
                withId: TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza.id!,
                inShowWithId: dumpweedExtravaganza.id
            )
            XCTFail("This fetch should've failed because the DrumKitBacklineItem was deleted")
        } catch Swift.DecodingError.valueNotFound {
            XCTAssert(true)
        } catch {
            XCTFail("The only error that should be thrown here is a Swift.DecodingError.valueNotFound.")
        }

        try await testingDatabaseService.createDrumKitBacklineItem(
            create: TestingConstants.exampleDrumKitBacklineItemDumpweedExtravaganza,
            in: dumpweedExtravaganza
        )
    }
}
