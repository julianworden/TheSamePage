//
//  ChooseNewBandAdminViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/1/23.
//

import Foundation

@MainActor
final class ChooseNewBandAdminViewModel: ObservableObject {
    /// The users playing in a band. If the band admin also plays in this band, they will not appear in this array.
    @Published var usersPlayingInBand = [User]()

    @Published var selectNewBandAdminConfirmationAlertIsShowing = false
    @Published var bandAdminIsBeingSet = false
    @Published var newAdminSelectionWasSuccessful = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                bandAdminIsBeingSet = true
            case .workCompleted:
                newAdminSelectionWasSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                bandAdminIsBeingSet = false
            default:
                if viewState != .dataLoading && viewState != .dataLoaded && viewState != .dataNotFound {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    var band: Band

    init(band: Band) {
        self.band = band
    }

    func getUsersPlayingInBand() async {
        do {
            viewState = .dataLoading
            usersPlayingInBand = try await DatabaseService.shared.getUsersPlayingInBand(band: band)

            usersPlayingInBand.isEmpty ? (viewState = .dataNotFound) : (viewState = .dataLoaded)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func setNewBandAdmin(user: User) async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.setNewBandAdmin(user: user, band: band)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
