//
//  TestingConstants.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/18/22.
//

@testable import TheSamePage

import UIKit.UIImage
import FirebaseFirestore
import Foundation

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

    // MARK: - Example Bands

    /// An example band that matches a band being stored in Firestore Emulator
    static let exampleBandPatheticFallacy = Band(
        id: "C7ZbA7gaeQ7Lk1Kid9QC",
        name: "Pathetic Fallacy",
        bio: "We're a metal core band from central New Jersey!",
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
        adminUid: exampleUserEric.id,
        memberUids: [exampleUserEric.id],
        genre: Genre.metal.rawValue,
        city: "New Brunswick",
        state: BandState.NJ.rawValue
    )

    // MARK: - Example BandMembers

    static let exampleBandMemberJulian = BandMember(
        id: "JcNG3facFtTva2scVKDZ",
        dateJoined: 1673073450,
        uid: "qvJ5tmKpih3mFkUCet5CPREg3qjZ",
        role: "Vocals",
        username: "julianworden",
        fullName: "Julian Worden"
    )

    static let exampleBandMemberLou = BandMember(
        id: "KgjxDt61nxsNMR4PSvdO",
        dateJoined: 1673073450,
        uid: "CsXJnPfi5ZT9jr2uQUsO4jz040Et",
        role: "Guitar",
        username: "lousabba",
        fullName: "Lou Sabba"
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
        hostUid: "qvJ5tmKpih3mFkUCet5CPREg3qjZ",
        bandIds: [],
        participantUids: [],
        venue: "Starland Ballroom",
        date: 1668782049.620614,
        loadInTime: nil,
        doorsTime: nil,
        musicStartTime: nil,
        endTime: nil,
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
        imageUrl: "http://localhost:9199/v0/b/the-same-page-9c69e.appspot.com/o/images%2F24088E5A-F780-49FF-A2B2-ED841D40AF1C.jpg?alt=media&token=2199fdad-0868-4f75-b005-794933e5b9c3",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: "Rock",
        maxNumberOfBands: 2
    )

    // MARK: - Example BandInvites

    /// An example band invite inviting exampleUserTas to join Pathetic Fallacy. Sent by exampleUserJulian.
    static let exampleBandInvite = BandInvite(
        id: "I8jPC6U14IolWMSc8Ivp",
        dateSent: 1673073450,
        notificationType: NotificationType.bandInvite.rawValue,
        recipientUid: "FNl8cxPCoELjL8WsxRfliNP0Lmhq",
        recipientRole: "Drums",
        bandId: "C7ZbA7gaeQ7Lk1Kid9QC",
        senderUsername: "julianworden",
        senderBand: "Pathetic Fallacy",
        message: "julianworden is inviting you to join Pathetic Fallacy"
    )

    // MARK: - Example Chats

    static let exampleChatDumpweedExtravaganza = Chat(
        id: "cpS2HseZT6XIG1qMRAKL",
        showId: exampleShowDumpweedExtravaganza.id,
        name: "Dumpweed Extravaganza",
        participantUids: [exampleUserJulian.id, exampleUserLou.id, exampleUserEric.id]
    )
}
