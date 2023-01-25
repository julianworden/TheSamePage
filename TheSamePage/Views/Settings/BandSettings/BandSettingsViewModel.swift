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

    // TODO: Allow for a band to be deleted in this view
}
