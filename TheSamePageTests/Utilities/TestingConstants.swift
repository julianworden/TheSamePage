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
    static let showForUpdateShowTests = Show(
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
