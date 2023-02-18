//
//  AddMyBandToShowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/19/23.
//

import Foundation

@MainActor
final class AddMyBandToShowViewModel: ObservableObject {
    @Published var userBands = [Band]()
    /// The band that will be added to the show.
    @Published var selectedBand: Band?
    @Published var buttonsAreDisabled = false
    @Published var bandAddedSuccessfully = false

    let show: Show

    @Published var invalidRequestAlertIsShowing = false
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    var invalidRequestAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                bandAddedSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataNotFound && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }

    init(show: Show) {
        self.show = show
    }

    func getLoggedInUserAdminBands() async {
        do {
            userBands = try await DatabaseService.shared.getAdminBands(withUid: AuthController.getLoggedInUid())

            if !userBands.isEmpty {
                selectedBand = userBands.first
                viewState = .dataLoaded
            } else {
                viewState = .dataNotFound
            }
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func addBandToShow() async {
        guard let selectedBand else {
            viewState = .error(message: "Failed to add band to show. Please try again later")
            return
        }

        guard addBandToShowRequestIsValid(with: selectedBand) else { return }

        do {
            let newShowParticipant = ShowParticipant(
                name: selectedBand.name,
                bandId: selectedBand.id,
                bandAdminUid: selectedBand.adminUid,
                showId: show.id
            )

            try await DatabaseService.shared.addBandToShow(add: selectedBand, as: newShowParticipant, to: show)

            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func addBandToShowRequestIsValid(with band: Band) -> Bool {
        guard !show.lineupIsFull else {
            invalidRequestAlertText = ErrorMessageConstants.showLineupIsFullOnSendShowInvite
            invalidRequestAlertIsShowing = true
            return false
        }

        guard !show.bandIds.contains(band.id) else {
            invalidRequestAlertText = ErrorMessageConstants.bandIsAlreadyPlayingShow
            invalidRequestAlertIsShowing = true
            return false
        }

        return true
    }
}
