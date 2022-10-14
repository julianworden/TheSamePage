//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import Foundation

class ShowDetailsViewModel: ObservableObject {
    let show: Show
    let showName: String
    let showDescription: String
    let showDate: String
    let showGenre: String
    let showHost: String
    let showTicketPrice: Double?
    let showTicketSalesAreRequired: Bool
    let showMinimumRequiredTicketsSold: Int?
    let showVenue: String
    let showImageUrl: String?
    let showHasFood: Bool
    let showHasBar: Bool
    let showIs21Plus: Bool
    let showMaxNumberOfBands: Int
    let showFormattedTicketPrice: String?
    @Published var showLineup = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    
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
        self.showDescription = show.description ?? ""
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
        
        Task {
            do {
                try await getShowLineup()
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    func getShowLineup() async throws {
        showLineup = try await DatabaseService.shared.getShowLineup(forShow: show)
    }
}
