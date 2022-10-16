//
//  AddEditShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import Contacts
import FirebaseFirestore
import GeoFireUtils
import MapKit
import UIKit.UIImage

class AddEditShowViewModel: ObservableObject {
    var showToEdit: Show?
    let viewTitleText: String
    
    @Published var showName = ""
    @Published var showDescription = ""
    @Published var showVenue = ""
    @Published var showHostName = ""
    @Published var showGenre = Genre.rock
    @Published var showMaxNumberOfBands = 1
    @Published var showDate = Date()
    
    @Published var queryText = ""
    @Published var addressSearchResults = [CLPlacemark]()
    @Published var addressIsPubliclyVisible = true
    var showAddress: String?
    var showCity: String?
    var showState: String?
    var showLatitude: Double = 0
    var showLongitude: Double = 0
    var showGeohash = ""
    var addressSearch: MKLocalSearch?
    
    @Published var ticketPrice = ""
    @Published var ticketSalesAreRequired = false
    @Published var minimumRequiredTicketsSold = ""
    @Published var showIs21Plus = false
    @Published var showHasBar = false
    @Published var showHasFood = false
    
    var publiclyVisibleAddressExplanation: String {
        if addressIsPubliclyVisible {
            return "Anybody can see this show's address"
        } else {
            return "Anybody can see this show's city and state, but only this show's participants can see the full address"
        }
    }
    
    init(viewTitleText: String, showToEdit: Show?) {
        self.showToEdit = showToEdit
        self.viewTitleText = viewTitleText
    }
    
    func incrementMaxNumberOfBands() {
        if showMaxNumberOfBands < 101 {
            showMaxNumberOfBands += 1
        }
    }
    
    func decrementMaxNumberOfBands() {
        if showMaxNumberOfBands > 1 {
            showMaxNumberOfBands -= 1
        }
    }
    
    func search(withText text: String) async throws {
        let searchRequest = MKLocalSearch.Request()
        if let userRegion = LocationController.shared.userRegion {
            searchRequest.region = userRegion
        }
        
        searchRequest.naturalLanguageQuery = text
        
        addressSearch = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await addressSearch!.start()
            
            Task { @MainActor in
                addressSearchResults = response.mapItems.map { $0.placemark }
                addressSearch?.cancel()
            }
        } catch {
            print("\(error) search failed")
        }
    }
    
    func setShowLocationInfo(withPlacemark placemark: CLPlacemark) {
        if let showLatitude = placemark.location?.coordinate.latitude,
           let showLongitude = placemark.location?.coordinate.longitude {
                let showCoordinates = CLLocationCoordinate2D(latitude: showLatitude, longitude: showLongitude)
                self.showLatitude = showLatitude
                self.showLongitude = showLongitude
                showGeohash = GFUtils.geoHash(forLocation: showCoordinates)
        }
        
        showAddress = placemark.formattedAddress
        showCity = placemark.postalAddress?.city
        showState = placemark.postalAddress?.state
    }
    
    func createShow(withImage image: UIImage?) async throws {
        var newShow: Show

        if let image {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newShow = Show(
                id: "",
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                ticketPrice: Double(ticketPrice),
                ticketSalesAreRequired: ticketSalesAreRequired,
                minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
                addressIsPrivate: addressIsPubliclyVisible,
                address: showAddress ?? "Unknown Address",
                city: showCity ?? "Unknown City",
                state: showState ?? "Unknown State",
                latitude: showLatitude,
                longitude: showLongitude,
                geohash: showGeohash,
                imageUrl: imageUrl,
                hasFood: showHasFood,
                hasBar: showHasBar,
                is21Plus: showIs21Plus,
                genre: showGenre.rawValue,
                maxNumberOfBands: showMaxNumberOfBands
            )
        } else {
            newShow = Show(
                id: "",
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                ticketPrice: Double(ticketPrice),
                ticketSalesAreRequired: ticketSalesAreRequired,
                minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
                addressIsPrivate: addressIsPubliclyVisible,
                address: showAddress ?? "Unknown Address",
                city: showCity ?? "Unknown City",
                state: showState ?? "Unknown State",
                latitude: showLatitude,
                longitude: showLongitude,
                geohash: showGeohash,
                hasFood: showHasFood,
                hasBar: showHasBar,
                is21Plus: showIs21Plus,
                genre: showGenre.rawValue,
                maxNumberOfBands: showMaxNumberOfBands
            )
        }
        
        try await DatabaseService.shared.createShow(show: newShow)
    }
}
