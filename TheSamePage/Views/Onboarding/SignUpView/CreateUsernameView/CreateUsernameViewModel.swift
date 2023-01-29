//
//  CreateUsernameViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/27/23.
//

import FirebaseAuth
import Foundation

@MainActor
final class CreateUsernameViewModel: ObservableObject {
    @Published var username = ""

    @Published var createUsernameButtonIsDisabled = false
    @Published var usernameCreationWasSuccessfulAlertIsShowing = false

    @Published var errorAlertIsShowing = false
    var errorAlertText = ""

    @Published var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                createUsernameButtonIsDisabled = true
            case .workCompleted:
                usernameCreationWasSuccessfulAlertIsShowing = true
            case .error(let message):
                errorAlertText = message
                errorAlertIsShowing = true
                createUsernameButtonIsDisabled = false
            default:
                errorAlertText = ErrorMessageConstants.invalidViewState
                errorAlertIsShowing = true
            }
        }
    }

    func usernameIsValid() async throws -> Bool {
        guard username.count >= 3 else {
            viewState = .error(message: ErrorMessageConstants.usernameIsTooShort)
            return false
        }

        guard try await DatabaseService.shared.newUsernameIsNotAlreadyTaken(username.lowercasedAndTrimmed) else {
            viewState = .error(message: ErrorMessageConstants.usernameIsAlreadyTaken)
            return false
        }

        return true
    }

    func createUsername() async {
        do {
            viewState = .performingWork

            guard try await usernameIsValid() else {
                return
            }

            try await DatabaseService.shared.createUsername(username.lowercasedAndTrimmed)
            viewState = .workCompleted
        } catch {
            viewState = .error(message: error.localizedDescription)
        }
    }
}
