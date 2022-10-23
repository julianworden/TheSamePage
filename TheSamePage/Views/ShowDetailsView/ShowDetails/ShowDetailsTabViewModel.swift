//
//  ShowDetailsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/22/22.
//

import FirebaseFirestore
import Foundation

class ShowDetailsTabViewModel: ObservableObject {
    var show: Show
    @Published var showDescription = ""
    @Published var showHost = ""
    @Published var showHasFood: Bool
    @Published var showHasBar: Bool
    @Published var showIs21Plus: Bool
    @Published var showTicketSalesAreRequired: Bool
    @Published var showMinimumRequiredTicketsSold: Int?
    @Published var showTicketPrice: Double?
    @Published var showFormattedTicketPrice: String?
    
    let db = Firestore.firestore()
    var showListener: ListenerRegistration?
    
    init(show: Show) {
        self.show = show
        self.showDescription = show.description ?? ""
        self.showHost = show.host
        self.showHasFood = show.hasFood
        self.showHasBar = show.hasBar
        self.showIs21Plus = show.is21Plus
        self.showTicketSalesAreRequired = show.ticketSalesAreRequired
        self.showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold
        self.showTicketPrice = show.ticketPrice
        self.showFormattedTicketPrice = show.formattedTicketPrice
        
        addShowListener()
    }
    
    func addShowListener() {
        showListener = db.collection("shows").document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    self.show = editedShow
                    self.showDescription = editedShow.description ?? ""
                    self.showHost = editedShow.host
                    self.showTicketPrice = editedShow.ticketPrice
                    self.showTicketSalesAreRequired = editedShow.ticketSalesAreRequired
                    self.showMinimumRequiredTicketsSold = editedShow.minimumRequiredTicketsSold
                    self.showHasFood = editedShow.hasFood
                    self.showHasBar = editedShow.hasBar
                    self.showIs21Plus = editedShow.is21Plus
                    self.showFormattedTicketPrice = editedShow.formattedTicketPrice
                }
            }
        }
    }
    
    func removeShowListener() {
        showListener?.remove()
    }
}
