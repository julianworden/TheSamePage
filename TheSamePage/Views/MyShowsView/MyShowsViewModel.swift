//
//  MyShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/20/22.
//

import FirebaseFirestore
import Foundation

@MainActor
class MyShowsViewModel: ObservableObject {
    @Published var playingShows = [Show]()
    @Published var hostedShows = [Show]()
    @Published var selectedShowType = ShowType.hosting
    @Published var state = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var hostedShowsListener: ListenerRegistration?
    var playingShowsListener: ListenerRegistration?
    
    /// Fetches all shows that the user is hosting.
    func getHostedShows() async throws {
        state = .dataLoading
        
        hostedShowsListener = db.collection("shows").whereField(
            "hostUid",
            isEqualTo: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task {
                    self.hostedShows = try await DatabaseService.shared.getHostedShows()
                    
                    if self.hostedShows.isEmpty {
                        self.state = .dataNotFound
                    } else {
                        self.state = .dataLoaded
                    }
                }
            } else if error != nil {
                self.state = .error(message: error!.localizedDescription)
            }
        }
    }
    
    /// Fetches all shows that the user is playing.
    func getPlayingShows() async throws {
        state = .dataLoading
        
        playingShowsListener = db.collection("shows").whereField(
            "participantUids",
            arrayContains: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task {
                    self.playingShows = try await DatabaseService.shared.getPlayingShows()
                    
                    if self.playingShows.isEmpty {
                        self.state = .dataNotFound
                    } else {
                        self.state = .dataLoaded
                    }
                }
            }
        }
    }
    
    func removePlayingShowsListener() {
        playingShowsListener?.remove()
    }
    
    func removeHostedShowsListener() {
        hostedShowsListener?.remove()
    }
}
