//
//  DeleteAccountConfirmationView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/30/23.
//

import SwiftUI

struct DeleteAccountConfirmationView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var deleteAccountButtonIsDisabled = false
    @State private var deleteAccountConfirmationAlertIsShowing = false
    @State private var accountDeletedSuccessfullyAlertIsShowing = false
    
    @State private var viewState = ViewState.displayingView {
        didSet {
            switch viewState {
            case .performingWork:
                deleteAccountButtonIsDisabled = true
            case .workCompleted:
                loggedInUserController.logOut()
            case .error(let message):
                loggedInUserController.errorMessageText = message
                loggedInUserController.errorMessageShowing = true
                deleteAccountButtonIsDisabled = false
            default:
                loggedInUserController.errorMessageText = ErrorMessageConstants.invalidViewState
                loggedInUserController.errorMessageShowing = true
            }
        }
    }

    var body: some View {
        VStack {
            Text("Tap the button below to permanently delete your account on The Same Page. **This cannot be reversed.** If you decide to delete your account, you can create a new one at any time.")
                .multilineTextAlignment(.center)

            Button(role: .destructive) {
                deleteAccountConfirmationAlertIsShowing.toggle()
            } label: {
                HStack(spacing: 5) {
                    Text("Delete Account")
                    if viewState == .performingWork {
                        ProgressView()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(deleteAccountButtonIsDisabled)
            .alert(
                "Are You Sure?",
                isPresented: $deleteAccountConfirmationAlertIsShowing,
                actions: {
                    Button("Cancel", role: .cancel) { }
                    Button("Yes", role: .destructive) {
                        Task {
                            viewState = .performingWork
                            await loggedInUserController.deleteAccount()
                        }
                    }
                },
                message: { Text("All of your data will be permanently deleted from The Same Page if you delete your account.") }
            )
        }
        .navigationBarBackButtonHidden(deleteAccountButtonIsDisabled ? true : false)
        .padding()
        .onChange(of: loggedInUserController.accountDeletionWasSuccessful) { accountDeletionWasSuccessful in
            if accountDeletionWasSuccessful {
                viewState = .workCompleted
            }
        }
    }
}

struct DeleteAccountConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                BackgroundColor()

                DeleteAccountConfirmationView()
                    .environmentObject(LoggedInUserController())
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
