//
//  BandSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/13/22.
//

import Foundation

@MainActor
final class BandSettingsViewModel: ObservableObject {
    @Published var band: Band

    @Published var deleteBandConfirmationAlertIsShowing = false
    @Published var buttonsAreDisabled = false
    @Published var bandDeleteWasSuccessful = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .performingWork:
                buttonsAreDisabled = true
            case .workCompleted:
                bandDeleteWasSuccessful = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                buttonsAreDisabled = false
            default:
                if viewState != .dataLoading && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
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

    func getLatestBandData() async {
        do {
            viewState = .dataLoading
            band = try await DatabaseService.shared.getBand(with: band.id)
            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
