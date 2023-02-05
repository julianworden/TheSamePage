//
//  ChangePasswordView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/30/23.
//

import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    @State private var newPassword = ""
    @State private var confirmedNewPassword = ""

    @State private var changePasswordButtonIsDisabled = false
    @State private var changePasswordConfirmationAlertIsShowing = false

    @State private var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                changePasswordButtonIsDisabled = true
            case .workCompleted:
                loggedInUserController.logOut()
                navigationViewModel.popToRoot()
            case .error(let message):
                loggedInUserController.errorMessageText = message
                loggedInUserController.errorMessageShowing = true
                changePasswordButtonIsDisabled = false
            default:
                loggedInUserController.errorMessageText = ErrorMessageConstants.invalidViewState
                loggedInUserController.errorMessageShowing = true
            }
        }
    }

    var body: some View {
        Form {
            Section {
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm Password", text: $confirmedNewPassword)
            }

            Section {
                Button("Change Password") {
                    changePasswordConfirmationAlertIsShowing.toggle()
                }
                .disabled(changePasswordButtonIsDisabled)
                .alert(
                    "Are You Sure?",
                    isPresented: $changePasswordConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            changePassword()
                        }
                    },
                    message: { Text("You will not be able to use The Same Page again until you log in again with your new password.") }
                )
            }
        }
        .navigationTitle("Change Password")
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            okButtonAction: {
                changePasswordButtonIsDisabled = false
            }
        )
        .onChange(of: loggedInUserController.passwordChangeWasSuccessful) { passwordChangeWasSuccessful in
            if passwordChangeWasSuccessful {
                viewState = .workCompleted
            }
        }
    }

    func changePassword() {
        guard newPassword == confirmedNewPassword else {
            loggedInUserController.viewState = .error(message: "The passwords do not match, please try again.")
            return
        }

        Task {
            viewState = .performingWork
            await loggedInUserController.changePassword(to: newPassword)
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
