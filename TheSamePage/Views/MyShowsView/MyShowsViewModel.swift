//
//  MyShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/20/22.
//

import FirebaseFirestore
import Foundation

class MyShowsViewModel: ObservableObject {
    @Published var playingShows = [Show]()
    @Published var hostedShows = [Show]()
    @Published var selectedShowType = ShowType.hosting
    
    let db = Firestore.firestore()
    var hostedShowsListener: ListenerRegistration?
    var playingShowsListener: ListenerRegistration?
    
    /// Fetches all shows that the user is either the host of or is participating in.
    func getHostedShows() async throws {
        hostedShowsListener = db.collection("shows").whereField(
            "hostUid",
            isEqualTo: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.hostedShows = try await DatabaseService.shared.getHostedShows()
                }
            }
        }
    }
    
    func getPlayingShows() async throws {
        playingShowsListener = db.collection("shows").whereField(
            "participantUids",
            arrayContains: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                Task { @MainActor in
                    self.playingShows = try await DatabaseService.shared.getPlayingShows()
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
