//
//  TestingConstants.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/18/22.
//

@testable import TheSamePage

import Contacts
import CoreLocation
import Intents
import FirebaseFirestore
import Foundation
import UIKit.UIImage

struct TestingConstants {
    static let uiImageForTesting = UIImage(systemName: "gear")

    // MARK: - Example Users

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserJulian = User(
        id: "qvJ5tmKpih3mFkUCet5CPREg3qjZ",
        name: "julianworden",
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/JMTech%20Profile%20Pic.jpeg?alt=media&token=511ccc65-8205-4d13-9802-74af76e42098",
        emailAddress: "julianworden@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserLou = User(
        id: "CsXJnPfi5ZT9jr2uQUsO4jz040Et",
        name: "lousabba",
        firstName: "Lou",
        lastName: "Sabba",
        emailAddress: "lousabba@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserTas = User(
        id: "FNl8cxPCoELjL8WsxRfliNP0Lmhq",
        name: "tascioppa",
        firstName: "Tas",
        lastName: "Cioppa",
        emailAddress: "tascioppa@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserEric = User(
        id: "K4rrOL8effR2ULYb3dDN5eMlXvWn",
        name: "ericpalermo",
        firstName: "Eric",
        lastName: "Palermo",
        emailAddress: "ericpalermo@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserMike = User(
        id: "0b5ozNAbBQ1ObJXNRCHDB4OjGzwi",
        name: "mikeflorentine",
        firstName: "Mike",
        lastName: "Florentine",
        emailAddress: "mikeflorentine@gmail.com"
    )

    static let exampleUserCraig = User(
        id: "pXKwVV75CSFjIlMOGU52oUVtELRt",
        name: "craigfederighi",
        firstName: "Craig",
        lastName: "Federighi",
        emailAddress: "craigfederighi@gmail.com"
    )

    static let exampleUserForIntegrationTesting = User(
        id: "XuGLWeK21EwCiTJgrhKZTPCCoSLk",
        name: "exampleuser",
        firstName: "Example",
        lastName: "User",
        emailAddress: "exampleuser@gmail.com"
    )

    static let exampleUserMattForIntegrationTesting = User(
        id: "",
        name: "mattdiguiseppe",
        firstName: "Matt",
        lastName: "Diguiseppe",
        emailAddress: "mattdiguiseppe@gmail.com"
    )

    static let exampleUserTimForIntegrationTesting = User(
        id: "",
        name: "timcook",
        firstName: "Tim",
        lastName: "Cook",
        emailAddress: "timcook@gmail.com"
    )

    // MARK: - Example Bands

    /// An example band that matches a band being stored in Firestore Emulator
    static let exampleBandPatheticFallacy = Band(
        id: "C7ZbA7gaeQ7Lk1Kid9QC",
        name: "Pathetic Fallacy",
        bio: "We're a metal core band from central New Jersey!",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/Pathetic%20Fallacy%20Band%20Photo.jpg?alt=media&token=1b89110a-6083-43de-b35b-4c1dfd1ad3f0",
        adminUid: exampleUserJulian.id,
        memberUids: [exampleUserJulian.id, exampleUserLou.id],
        genre: Genre.metalcore.rawValue,
        city: "Neptune",
        state: UsState.NJ.rawValue
    )

    /// An example band that matches a band being stored in Firestore Emulator
    static let exampleBandDumpweed = Band(
        id: "utwW2iCnJ7MiGAdRfFYz",
        name: "Dumpweed",
        bio: "We are the biggest rockers in the whole wide world!",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/Dumpweed%20Band%20Photo.jpg?alt=media&token=c80f3cd6-6aa0-4928-a7ae-bffeb0142636",
        adminUid: exampleUserEric.id,
        memberUids: [exampleUserEric.id],
        genre: Genre.metal.rawValue,
        city: "New Brunswick",
        state: UsState.NJ.rawValue
    )

    static let exampleBandTheApples = Band(
        id: "lptDfAu3fCXIObXxLVbx",
        name: "The Apples",
        bio: "We will woo you with our design chops, but our music is pretty cool too",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/Apple%20Logo.png?alt=media&token=0fc4c6d6-da4b-4b29-bfb4-57ef7c559b34",
        adminUid: exampleUserCraig.id,
        memberUids: [exampleUserCraig.id],
        genre: Genre.pop.rawValue,
        city: "Cupertino",
        state: UsState.CA.rawValue
    )

    static let exampleBandCraigAndTheFettuccinis = Band(
        id: "7ESwrNVI69a7MJFxrUTj",
        name: "Craig and the Fettuccinis",
        bio: "We make sick fettuccini while playing some tunes",
        adminUid: exampleUserCraig.id,
        memberUids: [exampleUserCraig.id],
        genre: Genre.deathcore.rawValue,
        city: "Cupertino",
        state: UsState.CA.rawValue
    )

    static let exampleBandForIntegrationTesting = Band(
        id: "",
        name: "Test Band Name",
        bio: "Test Band Bio",
        adminUid: exampleUserEric.id,
        memberUids: [exampleUserEric.id],
        genre: Genre.pop.rawValue,
        city: "Dallas",
        state: UsState.TX.rawValue
    )

    // MARK: - Example BandMembers

    static let exampleBandMemberJulian = BandMember(
        id: "JcNG3facFtTva2scVKDZ",
        dateJoined: 1673073450,
        uid: exampleUserJulian.id,
        role: Instrument.vocals.rawValue,
        username: exampleUserJulian.name,
        fullName: exampleUserJulian.fullName
    )

    static let exampleBandMemberLou = BandMember(
        id: "KgjxDt61nxsNMR4PSvdO",
        dateJoined: 1673073450,
        uid: exampleUserLou.id,
        role: Instrument.guitar.rawValue,
        username: exampleUserLou.name,
        fullName: exampleUserLou.fullName
    )

    static let exampleBandMemberEric = BandMember(
        id: "d6Nvz616sgY7zPll0Wh8",
        dateJoined: 1673073450,
        uid: exampleUserEric.id,
        role: Instrument.vocals.rawValue,
        username: exampleUserEric.name,
        fullName: exampleUserEric.fullName
    )

    static let exampleBandMemberCraigInTheApples = BandMember(
        id: "d6Nvz616sgY7zPll0Wh8",
        dateJoined: 1673073450,
        uid: exampleUserCraig.id,
        role: Instrument.guitar.rawValue,
        username: exampleUserCraig.name,
        fullName: exampleUserCraig.fullName
    )

    static let exampleBandMemberCraigInCraigAndTheFettuccinis = BandMember(
        id: "ajMaVPA9s0JiqojFLfvQ",
        dateJoined: 1674181413.480142,
        uid: exampleUserCraig.id,
        role: Instrument.guitar.rawValue,
        username: exampleUserCraig.name,
        fullName: exampleUserCraig.fullName
    )

    // MARK: - Example Shows

    /// An example show that matches a show being stored in Firestore Emulator
    static let exampleShowDumpweedExtravaganza = Show(
        id: "Kk1NYjptTJITr0pjfVbe",
        name: "Dumpweed Extravaganza",
        description: "A dank banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: "DAA Entertainment",
        hostUid: exampleUserJulian.id,
        bandIds: [exampleBandPatheticFallacy.id, exampleBandDumpweed.id],
        participantUids: [exampleUserJulian.id, exampleUserLou.id, exampleUserEric.id],
        venue: "Starland Ballroom",
        date: 1893484800,
        loadInTime: 1893556800,
        doorsTime: 1893558600,
        musicStartTime: 1893560400,
        endTime: 1893562200,
        isFree: false,
        ticketPrice: 100,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 20,
        addressIsPrivate: true,
        address: "570 Jernee Mill Rd, Sayreville, NJ 08872",
        city: "Sayreville",
        state: UsState.NJ.rawValue,
        latitude: 40.4404902,
        longitude: -74.355283,
        typesenseCoordinates: [40.4404902, -74.355283],
        imageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/DumpweedExtravaganzaPhoto.jpeg?alt=media&token=6e635dc8-dc74-4e8e-829a-79fba6eba4de",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 3,
        chatId: "cpS2HseZT6XIG1qMRAKL"
    )

    static let exampleShowAppleParkThrowdown = Show(
        id: "ReofZkUwFhRoTyVNFvvT",
        name: "Apple Park Throwdown",
        description: "We will be designing stuff while we play music",
        host: "Tim Cook Entertainment",
        hostUid: exampleUserCraig.id,
        bandIds: [exampleBandTheApples.id],
        participantUids: [exampleUserCraig.id],
        venue: "Apple Park",
        date: 1675065600,
        loadInTime: 1675134000,
        doorsTime: 1675135800,
        musicStartTime: 1675137600,
        endTime: 1675139400,
        isFree: false,
        ticketPrice: 1000,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 500,
        addressIsPrivate: false,
        address: "One Apple Park Way. Cupertino, CA 95014",
        city: "Cupertino",
        state: UsState.CA.rawValue,
        latitude: 37.332279,
        longitude: -122.010979,
        typesenseCoordinates: [37.332279, -122.010979],
        imageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/DumpweedExtravaganzaPhoto.jpeg?alt=media&token=6e635dc8-dc74-4e8e-829a-79fba6eba4de",
        hasFood: true,
        hasBar: false,
        is21Plus: false,
        genre: Genre.pop.rawValue,
        maxNumberOfBands: 3,
        chatId: "WiAizzEwGzQ3DFOg2Xop"
    )

    static let exampleShowForIntegrationTesting = Show(
        id: "",
        name: "Test Show Name",
        description: "Test Show Description",
        host: "Test Show Host",
        hostUid: exampleUserEric.id,
        bandIds: [exampleBandDumpweed.id],
        participantUids: [exampleUserEric.id],
        venue: "Test Venue",
        date: 1660806000,
        loadInTime: 1660870800,
        doorsTime: 1660872600,
        musicStartTime: 1660874400,
        endTime: 1660876200,
        isFree: false,
        ticketPrice: 200,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 50,
        addressIsPrivate: true,
        address: "151 3rd St, San Francisco, CA 94103",
        city: "San Francisco",
        state: UsState.CA.rawValue,
        latitude: 37.764420,
        longitude: -122.439890,
        typesenseCoordinates: [37.764420, -122.439890],
        imageUrl: nil,
        hasFood: true,
        hasBar: false,
        is21Plus: false,
        genre: Genre.pop.rawValue,
        maxNumberOfBands: 5
    )

    // MARK: - Example BandInvites

    /// An example band invite inviting exampleUserTas to join Pathetic Fallacy. Sent by exampleUserJulian.
    static let exampleBandInviteForTas = BandInvite(
        id: "I8jPC6U14IolWMSc8Ivp",
        recipientUsername: exampleUserTas.name,
        sentTimestamp: 1673073450,
        notificationType: NotificationType.bandInvite.rawValue,
        senderUid: exampleUserJulian.id,
        recipientUid: exampleUserTas.id,
        recipientRole: "Drums",
        bandId: exampleBandPatheticFallacy.id,
        senderUsername: exampleUserJulian.name,
        senderBand: exampleBandPatheticFallacy.name,
        message: "julianworden is inviting you to join Pathetic Fallacy"
    )

    static let exampleBandInviteForMatt = BandInvite(
        id: "",
        recipientUsername: exampleUserMattForIntegrationTesting.name,
        sentTimestamp: 1673073450,
        notificationType: NotificationType.bandInvite.rawValue,
        senderUid: exampleUserJulian.id,
        recipientUid: exampleUserMattForIntegrationTesting.id,
        recipientRole: "Bass Guitar",
        bandId: exampleBandPatheticFallacy.id,
        senderUsername: exampleUserJulian.name,
        senderBand: exampleBandPatheticFallacy.name,
        message: "julianworden is inviting you to join Pathetic Fallacy"
    )

    // MARK: - ExampleShowInvites

    static let exampleShowInviteForGenerationUnderground = ShowInvite(
        id: "",
        sentTimestamp: 1673565412,
        notificationType: NotificationType.showInvite.rawValue,
        senderUid: exampleUserJulian.id,
        recipientUid: exampleUserMike.id,
        bandName: "Generation Underground",
        bandId: "",
        showId: exampleShowDumpweedExtravaganza.id,
        showName: exampleShowDumpweedExtravaganza.name,
        showDate: exampleShowDumpweedExtravaganza.date,
        showVenue: exampleShowDumpweedExtravaganza.venue,
        showDescription: exampleShowDumpweedExtravaganza.description,
        senderUsername: exampleUserJulian.name,
        hasFood: exampleShowDumpweedExtravaganza.hasFood,
        hasBar: exampleShowDumpweedExtravaganza.hasBar,
        is21Plus: exampleShowDumpweedExtravaganza.is21Plus,
        message: "\(exampleUserJulian.name) is inviting Generation Underground to play \(exampleShowDumpweedExtravaganza.name) at \(exampleShowDumpweedExtravaganza.venue) on \(exampleShowDumpweedExtravaganza.formattedDate)"
    )

    // MARK: - Example ShowApplications

    static let exampleShowApplicationForDumpweedExtravaganza = ShowApplication(
        id: "LHN7T2KCPTS8utVIHlXF",
        recipientFcmToken: nil,
        sentTimestamp: 167604400436.8428,
        bandName: exampleBandTheApples.name,
        message: "\(exampleBandTheApples.name) wants to play \(exampleShowDumpweedExtravaganza.name).",
        recipientUid: exampleUserJulian.id,
        senderUid: exampleUserCraig.id,
        showId: exampleShowDumpweedExtravaganza.id,
        showName: exampleShowDumpweedExtravaganza.name,
        bandId: exampleBandTheApples.id
    )

    // MARK: - Example Chats

    static let exampleChatDumpweedExtravaganza = Chat(
        id: "cpS2HseZT6XIG1qMRAKL",
        type: ChatType.show.rawValue,
        showId: exampleShowDumpweedExtravaganza.id,
        name: exampleShowDumpweedExtravaganza.name,
        participantUids: [exampleUserJulian.id, exampleUserLou.id, exampleUserEric.id],
        participantUsernames: [exampleUserJulian.name, exampleUserLou.name, exampleUserEric.name],
        mostRecentMessageText: "Hell Yeah!",
        mostRecentMessageTimestamp: 1676406074.836448,
        mostRecentMessageSenderUsername: exampleUserLou.name,
        upToDateParticipantUids: [exampleUserLou.id]
    )

    // MARK: - Example ChatMessages

    static let exampleChatMessageJulian = ChatMessage(
        id: "qlzBxkm79HpuzZfaRhEl",
        text: "Hey, it's Julian!",
        senderUid: exampleUserJulian.id,
        chatId: exampleChatDumpweedExtravaganza.id,
        chatName: exampleShowDumpweedExtravaganza.name,
        chatType: ChatType.show.rawValue,
        senderFullName: exampleUserJulian.fullName,
        senderUsername: exampleUserJulian.name,
        sentTimestamp: 1673217276
    )

    static let exampleChatMessageEric = ChatMessage(
        id: "5ZYl0FjPf6fEHIAtnLjX",
        text: "Hey, it's Eric!",
        senderUid: exampleUserEric.id,
        chatId: exampleChatDumpweedExtravaganza.id,
        chatName: exampleShowDumpweedExtravaganza.name,
        chatType: ChatType.show.rawValue,
        senderFullName: exampleUserEric.fullName,
        senderUsername: exampleUserEric.name,
        sentTimestamp: 1673187671.7910519
    )

    // MARK: - Example PlatformLinks

    static let examplePlatformLinkPatheticFallacyInstagram = PlatformLink(
        id: "44nlImc9WbuhR9MbRMYc",
        platformName: LinkPlatform.instagram.rawValue,
        url: "https://www.instagram.com/p/BvfCVUinISu/"
    )

    static let examplePlatformLinkPatheticFallacyFacebook = PlatformLink(
        id: "1qsDTgUjO7sGbY18AzA7",
        platformName: LinkPlatform.facebook.rawValue,
        url: "https://www.facebook.com/PathFallacyBand"
    )

    // MARK: - Example ShowParticipants

    static let exampleShowParticipantPatheticFallacyInDumpweedExtravaganza = ShowParticipant(
        id: "KbfVkNKelH4JNBkO3CeW",
        name: exampleBandPatheticFallacy.name,
        bandId: exampleBandPatheticFallacy.id,
        bandAdminUid: exampleBandPatheticFallacy.adminUid,
        showId: exampleShowDumpweedExtravaganza.id,
        setTime: 1668826800
    )

    static let exampleShowParticipantDumpweedInDumpweedExtravaganza = ShowParticipant(
        id: "7QUOjTRZVLdlJ4EzdaLr",
        name: exampleBandDumpweed.name,
        bandId: exampleBandDumpweed.id,
        bandAdminUid: exampleBandDumpweed.adminUid,
        showId: exampleShowDumpweedExtravaganza.id
    )

    static let exampleShowParticipantTheApplesInAppleParkThrowdown = ShowParticipant(
        id: "6NoWme0DUx3y508uxjak",
        name: exampleBandTheApples.name,
        bandId: exampleBandTheApples.id,
        bandAdminUid: exampleBandTheApples.adminUid,
        showId: exampleShowAppleParkThrowdown.id
    )

    // MARK: - Example Backline

    static let exampleShowDumpweedExtravaganzaAllBackline: [any Backline] = [exampleElectricGuitarBacklineItemDumpweedExtravaganza, exampleBassGuitarBacklineItemDumpweedExtravaganza, exampleDrumKitPieceBacklineItemDumpweedExtravaganza, exampleAuxPercussionBacklineItemDumpweedExtravaganza, exampleDrumKitBacklineItemDumpweedExtravaganza]

    static let exampleElectricGuitarBacklineItemDumpweedExtravaganza = BacklineItem(
        id: "uaiGeXYUKkGRAgf1U7DS",
        backlinerUid: exampleUserJulian.id,
        backlinerFullName: exampleUserJulian.fullName,
        backlinerUsername: exampleUserJulian.name,
        type: BacklineItemType.electricGuitar.rawValue,
        name: ElectricGuitarGear.comboAmp.rawValue,
        notes: "Marshall"
    )

    static let exampleBassGuitarBacklineItemDumpweedExtravaganza = BacklineItem(
        id: "LVgcRJZ704y7g6ohpWVj",
        backlinerUid: exampleUserJulian.id,
        backlinerFullName: exampleUserJulian.fullName,
        backlinerUsername: exampleUserJulian.name,
        type: BacklineItemType.bassGuitar.rawValue,
        name: BassGuitarGear.cab.rawValue,
        notes: "Ampeg 8 X 12"
    )

    static let exampleDrumKitPieceBacklineItemDumpweedExtravaganza = BacklineItem(
        id: "1ia024xU5y71R6vngnIe",
        backlinerUid: exampleUserJulian.id,
        backlinerFullName: exampleUserJulian.fullName,
        backlinerUsername: exampleUserJulian.name,
        type: BacklineItemType.percussion.rawValue,
        name: DrumKitPiece.kick.rawValue,
        notes: "DW Kick"
    )

    static let exampleAuxPercussionBacklineItemDumpweedExtravaganza = BacklineItem(
        id: "8QZ2veMzoawxQaRcx1iE",
        backlinerUid: exampleUserJulian.id,
        backlinerFullName: exampleUserJulian.fullName,
        backlinerUsername: exampleUserJulian.name,
        type: BacklineItemType.percussion.rawValue,
        name: PercussionGearType.auxiliaryPercussion.rawValue,
        notes: "Congas"
    )

    static let exampleDrumKitBacklineItemDumpweedExtravaganza = DrumKitBacklineItem(
        id: "aG8zt3O28acN0f5uk2Oe",
        backlinerUid: exampleUserJulian.id,
        backlinerFullName: exampleUserJulian.fullName,
        backlinerUsername: exampleUserJulian.name,
        type: BacklineItemType.percussion.rawValue,
        name: PercussionGearType.fullKit.rawValue,
        notes: "Pearl kit with Ziljian Cymbals",
        includedKitPieces: ["Kick", "Snare", "5 Toms", "Hi-Hat", "5 Cymbals", "5 Cymbal Stands"]
    )

    // MARK: - Example Location Data

    static func getExampleShowDumpweedExtravaganzaPlacemark() -> CLPlacemark {
        MockLocationController.setAlaskaMockLocationControllerValues()
        let locationController = LocationController.shared
        let address = CNMutablePostalAddress()
        address.city = "Sayreville"
        address.state = "NJ"
        address.street = "Jernee Mill Rd."
        address.country = "USA"
        address.postalCode = "08872"

        return CLPlacemark(location: locationController.userLocation!, name: nil, postalAddress: address)
    }

    // MARK: - Example ChatMessages

    static let testMessageText = "Test Message"
}
