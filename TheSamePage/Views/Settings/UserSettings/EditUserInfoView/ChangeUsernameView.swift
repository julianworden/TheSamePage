//
//  ChangeUsernameView.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/5/23.
//

import SwiftUI

struct ChangeUsernameView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    @State private var newUsername = ""
    @State private var confirmedNewUsername = ""

    @State private var changeUsernameButtonIsDisabled = false
    @State private var changeUsernameConfirmationAlertIsShowing = false

    @State private var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                changeUsernameButtonIsDisabled = true
            case .workCompleted:
                navigationViewModel.popToRoot()
            case .error(let message):
                loggedInUserController.errorMessageText = message
                loggedInUserController.errorMessageShowing = true
                changeUsernameButtonIsDisabled = false
            case .displayingView:
                changeUsernameButtonIsDisabled = false
            default:
                loggedInUserController.errorMessageText = ErrorMessageConstants.invalidViewState
                loggedInUserController.errorMessageShowing = true
            }
        }
    }

    var body: some View {
        Form {
            Section {
                UsernameTextField("New Username", text: $newUsername)
                UsernameTextField("Confirm Username", text: $confirmedNewUsername)
            }

            Section {
                Button {
                    if newUsername == confirmedNewUsername {
                        changeUsernameConfirmationAlertIsShowing.toggle()
                    } else {
                        loggedInUserController.viewState = .error(message: "The usernames do not match, please try again.")
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text("Change Username")
                        if viewState == .performingWork {
                            ProgressView()
                        }
                    }
                }
                .disabled(changeUsernameButtonIsDisabled)
                .alert(
                    "Are You Sure?",
                    isPresented: $changeUsernameConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            changeUsername()
                        }
                    },
                    message: { Text("Your username will be changed to \(newUsername).") }
                )
            }
        }
        .navigationTitle("Change Username")
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            okButtonAction: {
                changeUsernameButtonIsDisabled = false
                viewState = .displayingView
            }
        )
        .onChange(of: loggedInUserController.usernameChangeWasSuccessful) { usernameChangeWasSuccessful in
            if usernameChangeWasSuccessful {
                viewState = .workCompleted
            }
        }
    }

    func changeUsername() {
        Task {
            viewState = .performingWork
            await loggedInUserController.changeUsername(to: newUsername)
        }
    }
}

struct ChangeUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeUsernameView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
