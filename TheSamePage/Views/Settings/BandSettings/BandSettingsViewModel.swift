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

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }
    
    init(band: Band) {
        self.band = band
    }
    
    func leaveBand() async {
        do {
            let user = try await DatabaseService.shared.getLoggedInUser()
            try await DatabaseService.shared.removeUserFromBand(user: user, band: band)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
