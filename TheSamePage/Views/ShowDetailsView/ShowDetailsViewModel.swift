//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import FirebaseFirestore
import Foundation
import MapKit

class ShowDetailsViewModel: ObservableObject {
    @Published var show: Show
    @Published var showName: String
    @Published var showDescription: String?
    @Published var showDate: String
    @Published var showGenre: String
    @Published var showHost: String
    @Published var showTicketPrice: Double?
    @Published var showTicketSalesAreRequired: Bool
    @Published var showMinimumRequiredTicketsSold: Int?
    @Published var showVenue: String
    @Published var showImageUrl: String?
    @Published var showHasFood: Bool
    @Published var showHasBar: Bool
    @Published var showIs21Plus: Bool
    @Published var showMaxNumberOfBands: Int
    @Published var showFormattedTicketPrice: String?
    @Published var showState: String
    @Published var showCity: String
    @Published var showLineup = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    
    @Published var state = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var showListener: ListenerRegistration?
    
    var showSlotsRemainingMessage: String {
        let slotsRemainingCount = showMaxNumberOfBands - showLineup.count
        
        if slotsRemainingCount == 1 {
            return "\(slotsRemainingCount) slot remaining"
        } else {
            return "\(slotsRemainingCount) slots remaining"
        }
    }
    
    init(show: Show) {
        self.show = show
        self.showName = show.name
        self.showDescription = show.description
        self.showDate = show.formattedDate
        self.showGenre = show.genre
        self.showHost = show.host
        self.showTicketPrice = show.ticketPrice
        self.showTicketSalesAreRequired = show.ticketSalesAreRequired
        self.showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold
        self.showVenue = show.venue
        self.showImageUrl = show.imageUrl
        self.showHasFood = show.hasFood
        self.showHasBar = show.hasBar
        self.showIs21Plus = show.is21Plus
        self.showFormattedTicketPrice = show.formattedTicketPrice
        self.showMaxNumberOfBands = show.maxNumberOfBands
        self.showState = show.state
        self.showCity = show.city
        
        Task {
            do {
                try await getShowLineup()
            } catch {
                state = .error(message: error.localizedDescription)
            }
        }
        
        state = .dataLoaded
        
        addShowListener()
    }
    
    func addShowListener() {
        showListener = db.collection("shows").document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    self.show = editedShow
                    self.showName = editedShow.name
                    self.showDescription = editedShow.description
                    self.showDate = editedShow.formattedDate
                    self.showGenre = editedShow.genre
                    self.showHost = editedShow.host
                    self.showTicketPrice = editedShow.ticketPrice
                    self.showTicketSalesAreRequired = editedShow.ticketSalesAreRequired
                    self.showMinimumRequiredTicketsSold = editedShow.minimumRequiredTicketsSold
                    self.showVenue = editedShow.venue
                    self.showImageUrl = editedShow.imageUrl
                    self.showHasFood = editedShow.hasFood
                    self.showHasBar = editedShow.hasBar
                    self.showIs21Plus = editedShow.is21Plus
                    self.showFormattedTicketPrice = editedShow.formattedTicketPrice
                    self.showMaxNumberOfBands = editedShow.maxNumberOfBands
                    self.showState = editedShow.state
                    self.showCity = editedShow.city
                }
            }
        }
    }
    
    @MainActor
    func getShowLineup() async throws {
        showLineup = try await DatabaseService.shared.getShowLineup(forShow: show)
    }
    
    func removeShowListener() {
        showListener?.remove()
    }
}
