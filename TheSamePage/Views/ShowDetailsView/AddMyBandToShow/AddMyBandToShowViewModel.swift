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
    @Published var addBandToShowButtonIsDisabled = false
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
                addBandToShowButtonIsDisabled = true
            case .workCompleted:
                bandAddedSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                addBandToShowButtonIsDisabled = false
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

    // TODO: This should get bands that the user is the admin of but is not a member of, too
    func getLoggedInUserBands() async {
        do {
            let fetchedBands = try await DatabaseService.shared.getBands(withUid: AuthController.getLoggedInUid())
            userBands = fetchedBands.filter { $0.adminUid == AuthController.getLoggedInUid() }

            if !userBands.isEmpty {
                selectedBand = userBands.first!
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
            viewState = .error(message: LogicError.unexpectedNilValue(message: "Failed to add band to show. Please try again later").localizedDescription)
            return
        }

        guard !show.lineupIsFull else {
            invalidRequestAlertText = ErrorMessageConstants.showLineupIsFull
            invalidRequestAlertIsShowing = true
            return
        }

        guard !show.bandIds.contains(selectedBand.id) else {
            invalidRequestAlertText = ErrorMessageConstants.bandIsAlreadyPlayingShow
            invalidRequestAlertIsShowing = true
            return
        }

        do {
            let newShowParticipant = ShowParticipant(
                name: selectedBand.name,
                bandId: selectedBand.id,
                showId: show.id
            )

            try await DatabaseService.shared.addBandToShow(add: selectedBand, as: newShowParticipant, to: show)

            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
