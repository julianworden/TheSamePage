//
//  ShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import FirebaseFirestore
import Foundation

class ShowsController: ObservableObject {
    @Published var nearbyShows = [Show]()
    @Published var playingShows = [Show]()
    @Published var hostedShows = [Show]()
    
    let db = Firestore.firestore()
    var hostedShowsListener: ListenerRegistration?
    
    func getShows() {
        nearbyShows = DatabaseService.shows
        // TODO: Implement showsNearYou = DatabaseService.getShowsNearYou() and remove above line
        playingShows = DatabaseService.shows
    }
    
    /// Fetches shows closest to the user based on their distance filter settings.
    func getShowsNearYou() {
        nearbyShows = DatabaseService.shared.getShowsNearYou()
    }
    
    /// Fetches all shows that the user is either the host of or is participating in.
    func getHostedShows() async throws {
        db.collection("shows").whereField(
            "hostUid",
            isEqualTo: AuthController.getLoggedInUid()
        ).addSnapshotListener(includeMetadataChanges: false) { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.hostedShows = try await DatabaseService.shared.getHostedShows()
                }
            }
        }
    }
    
    func removeShowListeners() {
        hostedShowsListener?.remove()
    }
}
