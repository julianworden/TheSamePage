//
//  ShowSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import Foundation

@MainActor
final class ShowSettingsViewModel: ObservableObject {
    @Published var cancelShowAlertIsShowing = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    @Published var show: Show

    @Published var viewState = ViewState.dataLoading {
        didSet {
            switch viewState {
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
            default:
                if viewState != .dataLoading && viewState != .dataLoaded {
                    errorAlertText = ErrorMessageConstants.invalidViewState
                    errorAlertIsShowing = true
                }
            }
        }
    }
    
    init(show: Show) {
        self.show = show
    }
    
    func cancelShow() async {
        do {
            try await DatabaseService.shared.cancelShow(show: show)
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }

    func getLatestShowData() async {
        do {
            viewState = .dataLoading
            show = try await DatabaseService.shared.getLatestShowData(showId: show.id)
            viewState = .dataLoaded
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
