//
//  Concert.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import MapKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

// TODO: Create individual properties for location
struct Show: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let host: String
    let hostUid: String
    var bandIds: [String]
    var participantUids: [String]
    let venue: String
    let date: Double
    let loadInTime: Double?
    let doorsTime: Double?
    let musicStartTime: Double?
    let endTime: Double?
    let ticketPrice: Double?
    let ticketSalesAreRequired: Bool
    let minimumRequiredTicketsSold: Int?
    let addressIsPrivate: Bool
    let address: String
    let city: String
    let state: String
    let latitude: Double
    let longitude: Double
    let geohash: String
    let imageUrl: String?
    let hasFood: Bool
    let hasBar: Bool
    let is21Plus: Bool
    let genre: String
    let maxNumberOfBands: Int
    
    init(id: String,
         name: String,
         description: String? = nil,
         host: String, hostUid: String,
         bandIds: [String] = [],
         participantUids: [String] = [],
         venue: String, date: Double,
         loadInTime: Double? = nil,
         doorsTime: Double? = nil,
         musicStartTime: Double? = nil,
         endTime: Double? = nil,
         ticketPrice: Double? = nil,
         ticketSalesAreRequired: Bool,
         minimumRequiredTicketsSold: Int? = nil,
         addressIsPrivate: Bool,
         address: String,
         city: String,
         state: String,
         latitude: Double,
         longitude: Double,
         geohash: String,
         imageUrl: String? = nil,
         hasFood: Bool,
         hasBar: Bool,
         is21Plus: Bool,
         genre: String,
         maxNumberOfBands: Int
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.host = host
        self.hostUid = hostUid
        self.bandIds = bandIds
        self.participantUids = participantUids
        self.venue = venue
        self.date = date
        self.loadInTime = loadInTime
        self.doorsTime = doorsTime
        self.musicStartTime = musicStartTime
        self.endTime = endTime
        self.ticketPrice = ticketPrice
        self.ticketSalesAreRequired = ticketSalesAreRequired
        self.minimumRequiredTicketsSold = minimumRequiredTicketsSold
        self.addressIsPrivate = addressIsPrivate
        self.address = address
        self.city = city
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.geohash = geohash
        self.imageUrl = imageUrl
        self.hasFood = hasFood
        self.hasBar = hasBar
        self.is21Plus = is21Plus
        self.genre = genre
        self.maxNumberOfBands = maxNumberOfBands
    }
    
    // TODO: Use a custom Date .formatted() extension for this instead
    var formattedDate: String {
        return TextUtility.formatDate(unixDate: date)
    }
    
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
    
    var loggedInUserIsShowParticipant: Bool {
        return participantUids.contains(AuthController.getLoggedInUid())
    }
    
    var loggedInUserIsNotInvolvedInShow: Bool {
        return !loggedInUserIsShowHost && !loggedInUserIsShowParticipant
    }
    
    var loggedInUserIsInvolvedInShow: Bool {
        return loggedInUserIsShowHost || loggedInUserIsShowParticipant
    }
    
    var addressIsVisibleToUser: Bool {
        return loggedInUserIsInvolvedInShow || !addressIsPrivate
    }
    
    var distanceFromUser: String? {
        if let userLocation = LocationController.shared.userLocation {
            let distanceInMeters = location.distance(from: userLocation)
            let measurementInMeters = Measurement(value: distanceInMeters, unit: UnitLength.meters)
            let formatter = MKDistanceFormatter()
            return formatter.string(fromDistance: measurementInMeters.value)
        } else {
            return nil
        }
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var region: MKCoordinateRegion {
        return MKCoordinateRegion(center: coordinates, latitudinalMeters: 500, longitudinalMeters: 500)
    }
    
    static let example = Show(
        id: "lawuehfaklwue",
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: "DAA Entertainment",
        hostUid: "",
        venue: "Starland Ballroom",
        date: Date().timeIntervalSince1970,
        ticketPrice: 100,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 20,
        addressIsPrivate: true,
        address: "4 Shorebrook Circle, Neptune NJ, 07753",
        city: "Neptune",
        state: "NJ",
        latitude: 2318273.1231,
        longitude: 14562378946.33,
        geohash: "hekfjawe2342",
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 2
    )
}
