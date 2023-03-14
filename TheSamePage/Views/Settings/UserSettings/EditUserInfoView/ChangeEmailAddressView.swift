//
//  EditEmailAddressView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct ChangeEmailAddressView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    @State private var newEmailAddress = ""
    @State private var confirmedNewEmailAddress = ""

    @State private var changeEmailAddressButtonIsDisabled = false
    @State private var changeEmailAddressConfirmationAlertIsShowing = false
    @State private var verificationEmailSentAlertIsShowing = false

    @State private var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .displayingView:
                changeEmailAddressButtonIsDisabled = false
            case .performingWork:
                changeEmailAddressButtonIsDisabled = true
            case .workCompleted:
                Task {
                    await loggedInUserController.logOut()
                }
                navigationViewModel.popToRoot()
            case .error(let message):
                loggedInUserController.errorMessageText = message
                loggedInUserController.errorMessageShowing = true
                changeEmailAddressButtonIsDisabled = false
            default:
                loggedInUserController.errorMessageText = ErrorMessageConstants.invalidViewState
                loggedInUserController.errorMessageShowing = true
            }
        }
    }

    var body: some View {
        Form {
            Section {
                CustomTextField("New Email Address", text: $newEmailAddress, keyboardType: .emailAddress)
                CustomTextField("Confirm Email Address", text: $confirmedNewEmailAddress, keyboardType: .emailAddress)
            } footer: {
                Text("Please be sure to enter a valid email address, you will need to verify it before you can use your account again.")
            }

            Section {
                Button {
                    if newEmailAddress == confirmedNewEmailAddress {
                        changeEmailAddressConfirmationAlertIsShowing.toggle()
                    } else {
                        loggedInUserController.viewState = .error(message: "The email addresses do not match, please try again.")
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text("Change Email Address")
                        if viewState == .performingWork {
                            ProgressView()
                        }
                    }
                }
                .disabled(changeEmailAddressButtonIsDisabled)
                .alert(
                    "Are You Sure?",
                    isPresented: $changeEmailAddressConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            changeEmailAddress()
                        }
                    },
                    message: { Text("You will not be able to use The Same Page again until you verify your new email address and log in again.") }
                )
            }
            .alert(
                "Success!",
                isPresented: $verificationEmailSentAlertIsShowing,
                actions: {
                    Button("OK", role: .cancel) { viewState = .workCompleted }
                },
                message: { Text("Please check your email inbox and tap the verification link to verify your new email address on The Same Page.") }
            )
        }
        .navigationTitle("Change Email Address")
        .scrollDismissesKeyboard(.interactively)
        .errorAlert(
            isPresented: $loggedInUserController.errorMessageShowing,
            message: loggedInUserController.errorMessageText,
            okButtonAction: {
                viewState = .displayingView
            }
        )
        .onChange(of: loggedInUserController.emailAddressChangeWasSuccessful) { emailAddressChangeWasSuccessful in
            if emailAddressChangeWasSuccessful {
                verificationEmailSentAlertIsShowing.toggle()
            }
        }
    }

    func changeEmailAddress() {
        Task {
            viewState = .performingWork
            await loggedInUserController.changeEmailAddress(to: newEmailAddress)
        }
    }
}

struct EditEmailAddressView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailAddressView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
