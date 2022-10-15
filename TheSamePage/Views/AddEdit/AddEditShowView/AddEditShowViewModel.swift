//
//  AddEditShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import Contacts
import FirebaseFirestore
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
    @Published var ticketPrice = ""
    @Published var ticketSalesAreRequired = false
    @Published var minimumRequiredTicketsSold = ""
    @Published var showIs21Plus = false
    @Published var showHasBar = false
    @Published var showHasFood = false
    
    @Published var queryText = ""
    @Published var addressSearchResults = [CLPlacemark]()
    var showAddress: String?
    var search: MKLocalSearch?
    
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
        
        search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search!.start()
            
            Task { @MainActor in
                addressSearchResults = response.mapItems.map { $0.placemark }
                search?.cancel()
            }
        } catch {
            print("\(error) search failed")
        }
    }
    
    func createShow(withImage image: UIImage?) async throws {
        var newShow: Show
        
        if let image {
            let imageUrl = try await DatabaseService.shared.uploadImage(image: image)
            newShow = Show(
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                bandIds: [],
                participantUids: [],
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                loadInTime: nil,
                doorsTime: nil,
                musicStartTime: nil,
                endTime: nil,
                ticketPrice: Double(ticketPrice),
                ticketSalesAreRequired: ticketSalesAreRequired,
                minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
                imageUrl: imageUrl,
                hasFood: showHasFood,
                hasBar: showHasBar,
                is21Plus: showIs21Plus,
                genre: showGenre.rawValue,
                maxNumberOfBands: showMaxNumberOfBands
            )
        } else {
            newShow = Show(
                name: showName,
                description: showDescription,
                host: showHostName,
                hostUid: AuthController.getLoggedInUid(),
                bandIds: [],
                participantUids: [],
                venue: showVenue,
                date: showDate.timeIntervalSince1970,
                loadInTime: nil,
                doorsTime: nil,
                musicStartTime: nil,
                endTime: nil,
                ticketPrice: Double(ticketPrice),
                ticketSalesAreRequired: ticketSalesAreRequired,
                minimumRequiredTicketsSold: Int(minimumRequiredTicketsSold),
                imageUrl: nil,
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
