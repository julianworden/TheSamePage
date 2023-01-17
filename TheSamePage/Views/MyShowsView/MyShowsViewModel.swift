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
                myHostedShowsErrorAlertText = message
                myHostedShowsErrorAlertIsShowing = true
            default:
                if myHostedShowsViewState != .dataNotFound && myHostedShowsViewState != .dataLoaded {
                    myHostedShowsErrorAlertIsShowing = true
                    myHostedShowsErrorAlertText = ErrorMessageConstants.invalidViewState
                }
            }
        }
    }
    @Published var myPlayingShowsViewState = ViewState.dataLoading {
        didSet {
            switch myPlayingShowsViewState {
            case .error(let message):
                myPlayingShowsErrorAlertText = message
                myPlayingShowsErrorAlertIsShowing = true
            default:
                if myPlayingShowsViewState != .dataNotFound && myPlayingShowsViewState != .dataLoaded {
                    myPlayingShowsErrorAlertIsShowing = true
                    myPlayingShowsErrorAlertText = ErrorMessageConstants.invalidViewState
                }
            }
        }
    }

    @Published var myHostedShowsErrorAlertIsShowing = false
    var myHostedShowsErrorAlertText = ""
    
    @Published var myPlayingShowsErrorAlertIsShowing = false
    var myPlayingShowsErrorAlertText = ""
    
    let db = Firestore.firestore()
    
    /// Fetches all shows that the user is hosting.
    func getHostedShows() async {
        do {
            hostedShows = try await DatabaseService.shared.getHostedShows()
            hostedShows.isEmpty ? (myHostedShowsViewState = .dataNotFound) : (myHostedShowsViewState = .dataLoaded)
        } catch {
            myHostedShowsViewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Fetches all shows that the user is playing.
    func getPlayingShows() async {
        do {
            playingShows = try await DatabaseService.shared.getPlayingShows()
            playingShows.isEmpty ? (myPlayingShowsViewState = .dataNotFound) : (myPlayingShowsViewState = .dataLoaded)
        } catch {
            myPlayingShowsViewState = .error(message: error.localizedDescription)
        }
    }
}
