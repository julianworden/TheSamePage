//
//  Concert.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// TODO: Create individual properties for location
struct Show: Codable, Equatable, Hashable, Identifiable {
    var id: String?
    let name: String
    let description: String?
    let host: String
    let hostUid: String
    var bandIds: [String]?
    var participantUids: [String]?
    let venue: String
    let date: Double
    let loadInTime: Double?
    let doorsTime: Double?
    let musicStartTime: Double?
    let endTime: Double?
    let ticketPrice: Double?
    let ticketSalesAreRequired: Bool
    let minimumRequiredTicketsSold: Int?
    let imageUrl: String?
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let genre: String
    let maxNumberOfBands: Int
    
    var formattedDate: String {
        return TextUtility.formatDate(unixDate: date)
    }
    
//    var formattedDoorsTime: String? {
//        if let time {
//            return TextUtility.formatTime(unixTime: time.doors)
//        } else {
//            return nil
//        }
//    }
    
    var formattedTicketPrice: String? {
        if let ticketPrice {
            return ticketPrice.formatted(.currency(code: Locale.current.currencyCode ?? "USD"))
        } else {
            return nil
        }
    }
    
    var loggedInUserIsShowHost: Bool {
        return hostUid == AuthController.getLoggedInUid()
    }
    
    static let example = Show(
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: "DAA Entertainment",
        hostUid: "",
        bandIds: nil,
        participantUids: nil,
        venue: "Starland Ballroom",
        date: Date().timeIntervalSince1970,
        loadInTime: nil,
        doorsTime: nil,
        musicStartTime: nil,
        endTime: nil,
        ticketPrice: 100,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 20,
        imageUrl: nil,
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 2
    )
}
