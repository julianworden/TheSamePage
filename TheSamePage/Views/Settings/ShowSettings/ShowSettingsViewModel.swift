//
//  ShowSettingsViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/14/22.
//

import Foundation

@MainActor
final class ShowSettingsViewModel: ObservableObject {
    @Published var addEditShowSheetIsShowing = false
    @Published var cancelShowAlertIsShowing = false
    
    @Published var errorAlertIsShowing = false
    var errorAlertText = ""
    
    let show: Show

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
}
