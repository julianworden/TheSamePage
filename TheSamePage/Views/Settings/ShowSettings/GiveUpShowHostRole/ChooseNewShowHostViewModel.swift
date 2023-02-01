//
//  ChooseNewShowHostViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/31/23.
//

import Foundation

#warning("TEST")
@MainActor
final class ChooseNewShowHostViewModel: ObservableObject {
    /// The users participating in a show. If the show host is also a show participant, they will not appear in this array.
    @Published var usersParticipatingInShow = [User]()

    @Published var selectNewShowHostConfirmationAlertIsShowing = false
    @Published var showHostIsBeingSet = false
    @Published var newHostSelectionWasSuccessful = false
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                showHostIsBeingSet = true
            case .workCompleted:
                newHostSelectionWasSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                showHostIsBeingSet = false
            default:
                if viewState != .dataLoading && viewState != .dataLoaded && viewState != .dataNotFound {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    let show: Show

    init(show: Show) {
        self.show = show
    }

    func getUsersParticipatingInShow() async {
        do {
            viewState = .dataLoading
            usersParticipatingInShow = try await DatabaseService.shared.getUsersPlayingShow(show: show)

            usersParticipatingInShow.isEmpty ? (viewState = .dataNotFound) : (viewState = .dataLoaded)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func setNewShowHost(user: User) async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.setNewShowHost(user: user, show: show)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
