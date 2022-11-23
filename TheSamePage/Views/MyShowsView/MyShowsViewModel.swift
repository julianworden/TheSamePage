//
//  MyShowsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/20/22.
//

import FirebaseFirestore
import Foundation

@MainActor
final class MyShowsViewModel: ObservableObject {
    @Published var playingShows = [Show]()
    @Published var hostedShows = [Show]()
    @Published var selectedShowType = ShowType.hosting
    @Published var myHostedShowsViewState = ViewState.dataLoading {
        didSet {
            switch myHostedShowsViewState {
            case .error(let message):
                myHostedShowsErrorAlertIsShowing = true
                myHostedShowsErrorAlertText = message
            default:
                if myHostedShowsViewState != .dataNotFound && myHostedShowsViewState != .dataLoaded {
                    print("Unknown viewState provided in MyShowsViewModel's myHostedShowsViewState property")
                }
            }
        }
    }
    @Published var myPlayingShowsViewState = ViewState.dataLoading {
        didSet {
            switch myPlayingShowsViewState {
            case .error(let message):
                myPlayingShowsErrorAlertIsShowing = true
                myPlayingShowsErrorAlertText = message
            default:
                if myPlayingShowsViewState != .dataNotFound && myPlayingShowsViewState != .dataLoaded {
                    print("Unknown viewState provided in MyShowsViewModel's myPlayingShowsViewState property")
                }
            }
        }
    }
    @Published var myShowsRootViewState = ViewState.displayingView
    
    @Published var myHostedShowsErrorAlertIsShowing = false
    var myHostedShowsErrorAlertText = ""
    
    @Published var myPlayingShowsErrorAlertIsShowing = false
    var myPlayingShowsErrorAlertText = ""
    
    let db = Firestore.firestore()
    var hostedShowsListener: ListenerRegistration?
    var playingShowsListener: ListenerRegistration?
    
    /// Fetches all shows that the user is hosting.
    func getHostedShows() async {
        hostedShowsListener = db.collection(FbConstants.shows).whereField(
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
    func getPlayingShows() async {
        playingShowsListener = db.collection(FbConstants.shows).whereField(
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
            } else if error != nil {
                self.myPlayingShowsViewState = .error(message: "Failed to fetch shows. System error: \(error!.localizedDescription)")
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
