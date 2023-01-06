//
//  TestingConstants.swift
//  TheSamePageTests
//
//  Created by Julian Worden on 11/18/22.
//

@testable import TheSamePage

import UIKit.UIImage
import Foundation

struct TestingConstants {
    static let uiImageForTesting = UIImage(systemName: "gear")
    /// A user that should be imported into Firebase emulator when it starts
    static let exampleUserInEmulator = User(
        id: "qvJ5tmKpih3mFkUCet5CPREg3qjZ",
        username: "julianworden",
        firstName: "Julian",
        lastName: "Worden",
        profileImageUrl: "http://127.0.0.1:9199/v0/b/the-same-page-9c69e.appspot.com/o/JMTech%20Profile%20Pic.jpeg?alt=media&token=511ccc65-8205-4d13-9802-74af76e42098",
        emailAddress: "julianworden@gmail.com"
    )
    /// A band that should be imported into Firebase emulator when it starts
    static let exampleBandInEmulator = Band(
        id: "C7ZbA7gaeQ7Lk1Kid9QC",
        name: "Pathetic Fallacy",
        bio: "We're a metal core band from central New Jersey!",
        adminUid: "qvJ5tmKpih3mFkUCet5CPREg3qjZ",
        memberUids: ["qvJ5tmKpih3mFkUCet5CPREg3qjZ"],
        genre: "Metalcore",
        city: "Neptune",
        state: "NJ"
    )
    /// A show that should be imported into Firebase emulator when it starts
    static let exampleShowInEmulator = Show(
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
        state: "NJ",
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
}
