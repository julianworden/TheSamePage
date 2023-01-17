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
        XCTAssertEqual(sut.selectedGuitarGear, .comboAmp)
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
        XCTAssertFalse(sut.addGearButtonIsDisabled)
        XCTAssertFalse(sut.gearAddedSuccessfully)
        XCTAssertFalse(sut.errorAlertIsShowing)
        XCTAssertEqual(sut.numberOfTomsIncluded, 0)
        XCTAssertEqual(sut.numberOfCymbalsIncluded, 0)
        XCTAssertEqual(sut.numberOfCymbalStandsIncluded, 0)
        XCTAssertTrue(sut.errorAlertText.isEmpty)
        XCTAssertEqual(sut.show, dumpweedExtravaganza)
        XCTAssertEqual(sut.viewState, .displayingView)
    }

    func test_OnAddElectricGuitarBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .electricGuitar
        sut.selectedGuitarGear = .ampHead
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
        XCTAssertEqual(createdBacklineItem.name, GuitarGear.ampHead.rawValue)
        XCTAssertEqual(createdBacklineItem.notes, "Really great amp head")
    }

    func test_OnAddBassGuitarBacklineItemToShow_BacklineItemIsAdded() async throws {
        sut.selectedGearType = .bassGuitar
        sut.selectedGuitarGear = .comboAmp
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
        XCTAssertEqual(createdBacklineItem.name, GuitarGear.comboAmp.rawValue)
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
        XCTAssertEqual(createdDrumKitBacklineItem.kickIncluded, false)
        XCTAssertEqual(createdDrumKitBacklineItem.snareIncluded, false)
        XCTAssertEqual(createdDrumKitBacklineItem.tomsIncluded, true)
        XCTAssertEqual(createdDrumKitBacklineItem.numberOfTomsIncluded, 3)
        XCTAssertEqual(createdDrumKitBacklineItem.hiHatIncluded, true)
        XCTAssertEqual(createdDrumKitBacklineItem.cymbalsIncluded, true)
        XCTAssertEqual(createdDrumKitBacklineItem.numberOfCymbalsIncluded, 4)
        XCTAssertEqual(createdDrumKitBacklineItem.cymbalStandsIncluded, true)
        XCTAssertEqual(createdDrumKitBacklineItem.numberOfCymbalStandsIncluded, 4)
    }
}
