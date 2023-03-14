//
//  AddEditSetTimeViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/6/23.
//

import Foundation

@MainActor
class AddEditSetTimeViewModel: ObservableObject {
    @Published var bandSetTime = Date.now

    let show: Show
    let showParticipant: ShowParticipant

    @Published var setTimeChangedSuccessfully = false
    @Published var buttonsAreDisabled = false
    @Published var deleteSetTimeConfirmationAlertIsShowing = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                setTimeChangedSuccessfully = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    init(show: Show, showParticipant: ShowParticipant) {
        self.show = show
        self.showParticipant = showParticipant
        if let setTimeToEdit = showParticipant.setTime {
            self.bandSetTime = setTimeToEdit.unixDateAsDate
        } else {
            self.bandSetTime = show.date.unixDateAsDate
        }
    }

    func addEditSetTime() async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.addEditSetTime(newSetTime: bandSetTime, for: showParticipant, in: show)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func deleteSetTime() async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.deleteSetTime(for: showParticipant, in: show)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
