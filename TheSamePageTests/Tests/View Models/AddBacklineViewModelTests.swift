//
//  AddBacklineViewModelTests.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 1/17/23.
//

@testable import TheSamePage

import XCTest

@MainActor
final class AddBacklineViewModelTests: XCTestCase {
    var sut: AddBacklineViewModel!
    var testingDatabaseService: TestingDatabaseService!
    let dumpweedExtravaganza = TestingConstants.exampleShowDumpweedExtravaganza
    let lou = TestingConstants.exampleUserLou
    var createdBacklineDocumentId: String?

    override func setUp() async throws {
        testingDatabaseService = TestingDatabaseService()
        try await testingDatabaseService.logInToLouAccount()
        sut = AddBacklineViewModel(show: dumpweedExtravaganza)
    }

    override func tearDown() async throws {
        if let createdBacklineDocumentId {
            try await testingDatabaseService.deleteBacklineItem(
                withId: createdBacklineDocumentId,
                inShowWithId: dumpweedExtravaganza.id
            )
            self.createdBacklineDocumentId = nil
        }

        try testingDatabaseService.logOut()
        sut = nil
        testingDatabaseService = nil
    }

    func test_OnInit_DefaultValuesAreCorrect() {
        XCTAssertEqual(sut.selectedGearType, .electricGuitar)
        XCTAssertEqual(sut.selectedElectricGuitarGear, .comboAmp)
        XCTAssertEqual(sut.selectedBassGuitarGear, .comboAmp)
        XCTAssertEqual(sut.selectedAcousticGuitarGear, .amp)
        XCTAssertEqual(sut.selectedPercussionGearType, .fullKit)
        XCTAssertEqual(sut.selectedDrumKitPiece, .kick)
        XCTAssertEqual(sut.selectedAuxillaryPercussion, .congas)
        XCTAssertTrue(sut.backlineGearNotes.isEmpty)
        XCTAssertFalse(sut.kickIncluded)
        XCTAssertFalse(sut.snareIncluded)
        XCTAssertFalse(sut.tomsIncluded)
        XCTAssertFalse(sut.hiHatIncluded)
        XCTAssertFalse(sut.cymbalsIncluded)
        XCTAssertFalse(sut.cymbalStandsIncluded)
        XCTAssertFalse(sut.buttonsAreDisabled)
        XCTAssertFalse(sut.gearAddedSuccessfully)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.numberOfTomsIncluded, 1)
        XCTAssertEqual(sut.numberOfCymbalsIncluded, 1)
        XCTAssertEqual(sut.numberOfCymbalStandsIncluded, 1)
        XCTAssertTrue(sut.includedKitPieces.isEmpty)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnPerformingWorkViewState_PropertiesAreSet() async throws {
        sut.viewState = .performingWork

        XCTAssertTrue(sut.buttonsAreDisabled, "The button should be disabled while work is being performed.")
    }

    func test_OnWorkCompletedViewState_PropertiesAreSet() async throws {
        sut.viewState = .workCompleted

        XCTAssertTrue(sut.gearAddedSuccessfully, "The view should be dismissed if the user is not onboarding and the band is successfully created.")
        XCTAssertFalse(sut.buttonsAreDisabled, "The button should be re-enabled in case the view doesn't get dismissed automatically for some reason.")
    }

    func test_OnErrorViewState_PropertiesAreSet() {
        sut.viewState = .error(message: "AN ERROR HAPPENED")

        XCTAssertTrue(sut.errorAlertIsShowing, "An error alert should be presented.")
        XCTAssertEqual(sut.errorAlertText, "AN ERROR HAPPENED", "The error message should be assigned to the text property.")
        XCTAssertFalse(sut.buttonsAreDisabled, "The user should be able to retry after an error occurs.")
    }

    func test_OnInvalidViewState_PropertiesAreSet() {
        sut.viewState = .dataNotFound

        XCTAssertEqual(sut.errorAlertText, ErrorMessageConstants.invalidViewState)
        XCTAssertTrue(sut.errorAlertIsShowing)
    }

    func test_OnCreateIncludedKitPiecesArray_IncludedKitPiecesArrayIsCreated() {
        sut.kickIncluded = true
        sut.tomsIncluded = true
        sut.numberOfTomsIncluded = 3
        sut.cymbalsIncluded = true
        sut.numberOfCymbalsIncluded = 4

        sut.createIncludedKitPiecesArray()

        XCTAssertEqual(sut.includedKitPieces, ["Kick", "3 Toms", "4 Cymbals"])
    }

    func test_OnAddElectricGuitarBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .electricGuitar
        sut.selectedElectricGuitarGear = .ampHead
        sut.backlineGearNotes = "Really great amp head"

        createdBacklineDocumentId = await sut.addBacklineItemToShow()
        let createdBacklineItem = try await testingDatabaseService.getBacklineItem(
            withId: createdBacklineDocumentId!,
            inShowWithId: dumpweedExtravaganza.id
        )

        XCTAssertEqual(createdBacklineItem.id, createdBacklineDocumentId)
        XCTAssertEqual(createdBacklineItem.backlinerUid, lou.id)
        XCTAssertEqual(createdBacklineItem.backlinerFullName, lou.fullName)
        XCTAssertEqual(createdBacklineItem.type, BacklineItemType.electricGuitar.rawValue)
        XCTAssertEqual(createdBacklineItem.name, ElectricGuitarGear.ampHead.rawValue)
        XCTAssertEqual(createdBacklineItem.notes, "Really great amp head")
    }

    func test_OnAddBassGuitarBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .bassGuitar
        sut.selectedBassGuitarGear = .comboAmp
        sut.backlineGearNotes = "Really great combo amp"

        createdBacklineDocumentId = await sut.addBacklineItemToShow()
        let createdBacklineItem = try await testingDatabaseService.getBacklineItem(
            withId: createdBacklineDocumentId!,
            inShowWithId: dumpweedExtravaganza.id
        )

        XCTAssertEqual(createdBacklineItem.id, createdBacklineDocumentId)
        XCTAssertEqual(createdBacklineItem.backlinerUid, lou.id)
        XCTAssertEqual(createdBacklineItem.backlinerFullName, lou.fullName)
        XCTAssertEqual(createdBacklineItem.type, BacklineItemType.bassGuitar.rawValue)
        XCTAssertEqual(createdBacklineItem.name, BassGuitarGear.comboAmp.rawValue)
        XCTAssertEqual(createdBacklineItem.notes, "Really great combo amp")
    }

    func test_OnAddDrumKitPieceBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .percussion
        sut.selectedPercussionGearType = .kitPiece
        sut.selectedDrumKitPiece = .tom
        sut.backlineGearNotes = "The best tom you've ever heard"

        createdBacklineDocumentId = await sut.addBacklineItemToShow()
        let createdBacklineItem = try await testingDatabaseService.getBacklineItem(
            withId: createdBacklineDocumentId!,
            inShowWithId: dumpweedExtravaganza.id
        )

        XCTAssertEqual(createdBacklineItem.id, createdBacklineDocumentId)
        XCTAssertEqual(createdBacklineItem.backlinerUid, lou.id)
        XCTAssertEqual(createdBacklineItem.backlinerFullName, lou.fullName)
        XCTAssertEqual(createdBacklineItem.type, BacklineItemType.percussion.rawValue)
        XCTAssertEqual(createdBacklineItem.name, DrumKitPiece.tom.rawValue)
        XCTAssertEqual(createdBacklineItem.notes, "The best tom you've ever heard")
    }

    func test_OnAddAuxPercussionBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .percussion
        sut.selectedPercussionGearType = .auxillaryPercussion
        sut.selectedAuxillaryPercussion = .congas
        sut.backlineGearNotes = "The best congas you've ever heard"

        createdBacklineDocumentId = await sut.addBacklineItemToShow()
        let createdBacklineItem = try await testingDatabaseService.getBacklineItem(
            withId: createdBacklineDocumentId!,
            inShowWithId: dumpweedExtravaganza.id
        )

        XCTAssertEqual(createdBacklineItem.id, createdBacklineDocumentId)
        XCTAssertEqual(createdBacklineItem.backlinerUid, lou.id)
        XCTAssertEqual(createdBacklineItem.backlinerFullName, lou.fullName)
        XCTAssertEqual(createdBacklineItem.type, BacklineItemType.percussion.rawValue)
        XCTAssertEqual(createdBacklineItem.name, AuxillaryPercussion.congas.rawValue)
        XCTAssertEqual(createdBacklineItem.notes, "The best congas you've ever heard")
    }

    func test_OnAddFullDrumKitBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .percussion
        sut.selectedPercussionGearType = .fullKit
        sut.kickIncluded = false
        sut.snareIncluded = false
        sut.tomsIncluded = true
        sut.numberOfTomsIncluded = 3
        sut.hiHatIncluded = true
        sut.cymbalsIncluded = true
        sut.numberOfCymbalsIncluded = 4
        sut.cymbalStandsIncluded = true
        sut.numberOfCymbalStandsIncluded = 4
        sut.backlineGearNotes = "The best drum kit you've ever heard"

        createdBacklineDocumentId = await sut.addBacklineItemToShow()
        let createdDrumKitBacklineItem = try await testingDatabaseService.getDrumKitBacklineItem(
            withId: createdBacklineDocumentId!,
            inShowWithId: dumpweedExtravaganza.id
        )

        XCTAssertEqual(createdDrumKitBacklineItem.id, createdBacklineDocumentId)
        XCTAssertEqual(createdDrumKitBacklineItem.backlinerUid, lou.id)
        XCTAssertEqual(createdDrumKitBacklineItem.backlinerFullName, lou.fullName)
        XCTAssertEqual(createdDrumKitBacklineItem.type, BacklineItemType.percussion.rawValue)
        XCTAssertEqual(createdDrumKitBacklineItem.name, PercussionGearType.fullKit.rawValue)
        XCTAssertEqual(createdDrumKitBacklineItem.notes, "The best drum kit you've ever heard")
        XCTAssertEqual(createdDrumKitBacklineItem.includedKitPieces, ["3 Toms", "Hi-Hat", "4 Cymbals", "4 Cymbal Stands"])
    }
}
