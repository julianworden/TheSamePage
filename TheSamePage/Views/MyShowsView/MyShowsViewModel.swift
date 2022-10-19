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
    @Published var myHostedShowsViewState = ViewState.dataLoading
    @Published var myPlayingShowsViewState = ViewState.dataLoading
    
    let db = Firestore.firestore()
    var hostedShowsListener: ListenerRegistration?
    var playingShowsListener: ListenerRegistration?
    
    /// Fetches all shows that the user is hosting.
    func getHostedShows() async throws {        
        hostedShowsListener = db.collection("shows").whereField(
            "hostUid",
            isEqualTo: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                guard !snapshot!.documents.isEmpty else {
                    self.myHostedShowsViewState = .dataNotFound
                    return
                }
                
                if let hostedShows = try? snapshot!.documents.map({ try $0.data(as: Show.self) }) {
                    self.hostedShows = hostedShows
                    self.myHostedShowsViewState = .dataLoaded
                }
            } else if error != nil {
                self.myHostedShowsViewState = .error(message: error!.localizedDescription)
            }
        }
    }
    
    /// Fetches all shows that the user is playing.
    func getPlayingShows() async throws {
        playingShowsListener = db.collection("shows").whereField(
            "participantUids",
            arrayContains: AuthController.getLoggedInUid()
        ).addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                guard !snapshot!.documents.isEmpty else {
                    self.myPlayingShowsViewState = .dataNotFound
                    return
                }
                
                if let playingShows = try? snapshot!.documents.map({ try $0.data(as: Show.self) }) {
                    self.playingShows = playingShows
                    self.myPlayingShowsViewState = .dataLoaded
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
