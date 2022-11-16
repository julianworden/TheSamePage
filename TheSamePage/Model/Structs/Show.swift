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
    var loadInTime: Double?
    var doorsTime: Double?
    var musicStartTime: Double?
    var endTime: Double?
    let isFree: Bool
    let ticketPrice: Double?
    let ticketSalesAreRequired: Bool
    let minimumRequiredTicketsSold: Int?
    let addressIsPrivate: Bool
    let address: String
    let city: String
    let state: String
    let latitude: Double
    let longitude: Double
    let typesenseCoordinates: [Double]
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
         isFree: Bool,
         ticketPrice: Double? = nil,
         ticketSalesAreRequired: Bool,
         minimumRequiredTicketsSold: Int? = nil,
         addressIsPrivate: Bool,
         address: String,
         city: String,
         state: String,
         latitude: Double,
         longitude: Double,
         typesenseCoordinates: [Double],
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
        self.isFree = isFree
        self.ticketPrice = ticketPrice
        self.ticketSalesAreRequired = ticketSalesAreRequired
        self.minimumRequiredTicketsSold = minimumRequiredTicketsSold
        self.addressIsPrivate = addressIsPrivate
        self.address = address
        self.city = city
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.typesenseCoordinates = typesenseCoordinates
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
    
    var unixDateAsDate: Date {
        return Date(timeIntervalSince1970: date)
    }
    
    var unixLoadInTimeAsDate: Date? {
        if let loadInTime {
            return Date(timeIntervalSince1970: loadInTime)
        } else {
            return nil
        }
    }
    
    var unixDoorsTimeAsDate: Date? {
        if let doorsTime {
            return Date(timeIntervalSince1970: doorsTime)
        } else {
            return nil
        }
    }
    
    var unixMusicStartTimeAsDate: Date? {
        if let musicStartTime {
            return Date(timeIntervalSince1970: musicStartTime)
        } else {
            return nil
        }
    }
    
    var unixEndTimeAsDate: Date? {
        if let endTime {
            return Date(timeIntervalSince1970: endTime)
        } else {
            return nil
        }
    }
    
    var hasTime: Bool {
        return loadInTime != nil ||
               doorsTime != nil ||
               musicStartTime != nil ||
               endTime != nil
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
    
    var shouldDisplayIcons: Bool {
        return hasFood || hasBar || is21Plus
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
    
    var lineupIsFull: Bool {
        return maxNumberOfBands == bandIds.count
    }
    
    static let example = Show(
        id: "lawuehfaklwue",
        name: "Dumpweed Extravaganza",
        description: "A dank ass banger! Hop on the bill I freakin’ swear you won’t regret it! Like, it's gonna be the show of the absolute century, bro!",
        host: "DAA Entertainment",
        hostUid: "",
        venue: "Starland Ballroom",
        date: Date().timeIntervalSince1970,
        isFree: false,
        ticketPrice: 100,
        ticketSalesAreRequired: true,
        minimumRequiredTicketsSold: 20,
        addressIsPrivate: true,
        address: "4 Shorebrook Circle, Neptune NJ, 07753",
        city: "Neptune",
        state: "NJ",
        latitude: 2318273.1231,
        longitude: 14562378946.33,
        typesenseCoordinates: [2318273.1231, 14562378946.33],
        hasFood: true,
        hasBar: true,
        is21Plus: true,
        genre: Genre.rock.rawValue,
        maxNumberOfBands: 2
    )
}
