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
    // TODO: Make all properties optional to make the initializer cleaner and make it so that addShowListener is the only thing initializing these properties
    @Published var show: Show
    @Published var showLineup = [ShowParticipant]()
    @Published var selectedTab = SelectedShowDetailsTab.details
    @Published var state = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var showListener: ListenerRegistration?
    
    var showSlotsRemainingMessage: String {
        let slotsRemainingCount = show.maxNumberOfBands - showLineup.count
        
        if slotsRemainingCount == 1 {
            return "\(slotsRemainingCount) slot remaining"
        } else {
            return "\(slotsRemainingCount) slots remaining"
        }
    }
    
    init(show: Show) {
        self.show = show
        
        Task {
            do {
                try await getShowLineup()
            } catch {
                state = .error(message: error.localizedDescription)
            }
        }
        
        state = .dataLoaded
        
        if showListener == nil {
            addShowListener()
        }
    }
    
    func addShowListener() {
        showListener = db.collection("shows").document(show.id).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                if let editedShow = try? snapshot!.data(as: Show.self) {
                    self.show = editedShow
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
