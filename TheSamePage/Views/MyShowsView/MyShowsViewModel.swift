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
    @Published var upcomingPlayingShows = [Show]()
    @Published var upcomingHostedShows = [Show]()
    @Published var selectedShowType = ShowType.hosting
    @Published var addEditShowSheetIsShowing = false
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
            let allHostedShows = try await DatabaseService.shared.getLoggedInUserHostedShows()
            let upcomingHostedShows = allHostedShows.filter {
                !$0.alreadyHappened
            }
            self.upcomingHostedShows = upcomingHostedShows
            upcomingHostedShows.isEmpty ? (myHostedShowsViewState = .dataNotFound) : (myHostedShowsViewState = .dataLoaded)
        } catch {
            myHostedShowsViewState = .error(message: error.localizedDescription)
        }
    }
    
    /// Fetches all shows that the user is playing.
    func getPlayingShows() async {
        do {
            let allPlayingShows = try await DatabaseService.shared.getPlayingShows()
            let upcomingPlayingShows = allPlayingShows.filter {
                !$0.alreadyHappened
            }
            self.upcomingPlayingShows = upcomingPlayingShows
            upcomingPlayingShows.isEmpty ? (myPlayingShowsViewState = .dataNotFound) : (myPlayingShowsViewState = .dataLoaded)
        } catch {
            myPlayingShowsViewState = .error(message: error.localizedDescription)
        }
    }
}
