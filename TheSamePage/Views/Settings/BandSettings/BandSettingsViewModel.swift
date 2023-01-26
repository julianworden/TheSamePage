//
//  BandSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/13/22.
//

import Foundation

@MainActor
final class BandSettingsViewModel: ObservableObject {
    let band: Band

    @Published var deleteBandConfirmationAlertIsShowing = false
    @Published var deleteBandButtonIsDisabled = false
    @Published var bandDeleteWasSuccessful = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                deleteBandButtonIsDisabled = true
            case .workCompleted:
                bandDeleteWasSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                deleteBandButtonIsDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }
    
    init(band: Band) {
        self.band = band
    }

    func deleteBand() async {
        do {
            viewState = .performingWork
            try await DatabaseService.shared.deleteBand(band)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
