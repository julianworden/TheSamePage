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
        username: "julianworden",
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/JMTech%20Profile%20Pic.jpeg?alt=media&token=511ccc65-8205-4d13-9802-74af76e42098",
        emailAddress: "julianworden@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserLou = User(
        id: "CsXJnPfi5ZT9jr2uQUsO4jz040Et",
        username: "lousabba",
        firstName: "Lou",
        lastName: "Sabba",
        emailAddress: "lousabba@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserTas = User(
        id: "FNl8cxPCoELjL8WsxRfliNP0Lmhq",
        username: "tascioppa",
        firstName: "Tas",
        lastName: "Cioppa",
        emailAddress: "tascioppa@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserEric = User(
        id: "K4rrOL8effR2ULYb3dDN5eMlXvWn",
        username: "ericpalermo",
        firstName: "Eric",
        lastName: "Palermo",
        emailAddress: "ericpalermo@gmail.com"
    )

    /// An example user that matches a user being stored in Firestore Emulator
    static let exampleUserMike = User(
        id: "0b5ozNAbBQ1ObJXNRCHDB4OjGzwi",
        username: "mikeflorentine",
        firstName: "Mike",
        lastName: "Florentine",
        emailAddress: "mikeflorentine@gmail.com"
    )

    static let exampleUserForIntegrationTesting = User(
        id: "",
        username: "exampleuser",
        firstName: "Example",
        lastName: "User",
        emailAddress: "exampleuser@gmail.com"
    )

    static let exampleUserMattForIntegrationTesting = User(
        id: "",
        username: "mattdiguiseppe",
        firstName: "Matt",
        lastName: "Diguiseppe",
        emailAddress: "mattdiguiseppe@gmail.com"
    )

    static let exampleUserTimForIntegrationTesting = User(
        id: "",
        username: "timcook",
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
        state: BandState.NJ.rawValue
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
        state: BandState.NJ.rawValue
    )

    static let exampleBandForIntegrationTesting = Band(
        id: "",
        name: "Test Band Name",
        bio: "Test Band Bio",
        adminUid: exampleUserEric.id,
        memberUids: [exampleUserEric.id],
        genre: Genre.pop.rawValue,
        city: "Dallas",
        state: BandState.TX.rawValue
    )

    // MARK: - Example BandMembers

    static let exampleBandMemberJulian = BandMember(
        id: "JcNG3facFtTva2scVKDZ",
        dateJoined: 1673073450,
        uid: exampleUserJulian.id,
        role: "Vocals",
        username: exampleUserJulian.username,
        fullName: exampleUserJulian.fullName
    )

    static let exampleBandMemberLou = BandMember(
        id: "KgjxDt61nxsNMR4PSvdO",
        dateJoined: 1673073450,
        uid: exampleUserLou.id,
        role: "Guitar",
        username: exampleUserLou.username,
        fullName: exampleUserLou.fullName
    )

    static let exampleBandMemberEric = BandMember(
        id: "d6Nvz616sgY7zPll0Wh8",
        dateJoined: 1673073450,
        uid: "K4rrOL8effR2ULYb3dDN5eMlXvWn",
        role: "Vocals",
        username: "ericpalermo",
        fullName: "Eric Palermo"
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
        date: 1668782049.620614,
        loadInTime: 1668830410,
        doorsTime: 1668832210,
        musicStartTime: 1668834010,
        endTime: 1668835810,
        isFree: false,
        ticketPrice: 100,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 20,
        addressIsPrivate: true,
        address: "570 Jernee Mill Rd, Sayreville, NJ 08872",
        city: "Sayreville",
        state: BandState.NJ.rawValue,
        latitude: 40.4404902,
        longitude: -74.355283,
        typesenseCoordinates: [40.4404902, -74.355283],
        imageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/DumpweedExtravaganzaPhoto.jpeg?alt=media&token=6e635dc8-dc74-4e8e-829a-79fba6eba4de",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 2
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
        state: BandState.CA.rawValue,
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
        dateSent: 1673073450,
        notificationType: NotificationType.bandInvite.rawValue,
        recipientUid: exampleUserTas.id,
        recipientRole: "Drums",
        bandId: exampleBandPatheticFallacy.id,
        senderUsername: exampleUserJulian.username,
        senderBand: exampleBandPatheticFallacy.name,
        message: "julianworden is inviting you to join Pathetic Fallacy"
    )

    static let exampleBandInviteForMatt = BandInvite(
        id: "",
        dateSent: 1673073450,
        notificationType: NotificationType.bandInvite.rawValue,
        recipientUid: exampleUserMattForIntegrationTesting.id,
        recipientRole: "Bass Guitar",
        bandId: exampleBandPatheticFallacy.id,
        senderUsername: exampleUserJulian.username,
        senderBand: exampleBandPatheticFallacy.name,
        message: "julianworden is inviting you to join Pathetic Fallacy"
    )

    // MARK: - ExampleShowInvites

    static let exampleShowInviteForGenerationUnderground = ShowInvite(
        id: "",
        dateSent: 1673565412,
        notificationType: NotificationType.showInvite.rawValue,
        recipientUid: exampleUserMike.id,
        bandName: "Generation Underground",
        bandId: "",
        showId: exampleShowDumpweedExtravaganza.id,
        showName: exampleShowDumpweedExtravaganza.name,
        showDate: exampleShowDumpweedExtravaganza.date,
        showVenue: exampleShowDumpweedExtravaganza.venue,
        showDescription: exampleShowDumpweedExtravaganza.description,
        senderUsername: exampleUserJulian.username,
        hasFood: exampleShowDumpweedExtravaganza.hasFood,
        hasBar: exampleShowDumpweedExtravaganza.hasBar,
        is21Plus: exampleShowDumpweedExtravaganza.is21Plus,
        message: "\(exampleUserJulian.username) is inviting Generation Underground to play \(exampleShowDumpweedExtravaganza.name) at \(exampleShowDumpweedExtravaganza.venue) on \(exampleShowDumpweedExtravaganza.formattedDate)"
    )

    // MARK: - Example Chats

    static let exampleChatDumpweedExtravaganza = Chat(
        id: "cpS2HseZT6XIG1qMRAKL",
        showId: exampleShowDumpweedExtravaganza.id,
        name: exampleShowDumpweedExtravaganza.name,
        participantUids: [exampleUserJulian.id, exampleUserLou.id, exampleUserEric.id]
    )

    // MARK: - Example ChatMessages

    static let exampleChatMessageJulian = ChatMessage(
        id: "qlzBxkm79HpuzZfaRhEl",
        text: "Hey, it's Julian!",
        senderUid: exampleUserJulian.id,
        senderFullName: exampleUserJulian.fullName,
        sentTimestamp: 1673217276
    )

    static let exampleChatMessageEric = ChatMessage(
        id: "5ZYl0FjPf6fEHIAtnLjX",
        text: "Hey, it's Eric!",
        senderUid: exampleUserEric.id,
        senderFullName: exampleUserEric.fullName,
        sentTimestamp: 1673187671.7910519
    )

    // MARK: - Example PlatformLinks

    static let examplePlatformLinkPatheticFallacyInstagram = PlatformLink(
        id: "44nlImc9WbuhR9MbRMYc",
        platformName: LinkPlatform.instagram.rawValue,
        url: "\(LinkPlatform.instagram.urlPrefix)pathfallacyband"
    )

    static let examplePlatformLinkPatheticFallacyFacebook = PlatformLink(
        id: "1qsDTgUjO7sGbY18AzA7",
        platformName: LinkPlatform.facebook.rawValue,
        url: "\(LinkPlatform.facebook.urlPrefix)pathfallacyband/posts/?ref=page_internal"
    )

    // MARK: - Example ShowParticipants

    static let exampleShowParticipantPatheticFallacyInDumpweedExtravaganza = ShowParticipant(
        id: "KbfVkNKelH4JNBkO3CeW",
        name: exampleBandPatheticFallacy.name,
        bandId: exampleBandPatheticFallacy.id,
        showId: exampleShowDumpweedExtravaganza.id
    )

    static let exampleShowParticipantDumpweedInDumpweedExtravaganza = ShowParticipant(
        id: "7QUOjTRZVLdlJ4EzdaLr",
        name: exampleBandDumpweed.name,
        bandId: exampleBandDumpweed.id,
        showId: exampleShowDumpweedExtravaganza.id
    )

    // MARK: - Example Location Data

    static func getExampleShowDumpweedExtravaganzaPlacemark() -> CLPlacemark {
        MockController.setSanFranciscoMockLocationControllerValues()
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
