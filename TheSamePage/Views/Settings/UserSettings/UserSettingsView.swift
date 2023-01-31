//
//  UserSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @StateObject private var viewModel = UserSettingsViewModel()
    @StateObject private var navigationViewModel = UserSettingsNavigationViewModel()

    @State private var logOutConfirmationAlertIsShowing = false

    var body: some View {
        NavigationStack(path: $navigationViewModel.navigationPath) {
            ZStack {
                BackgroundColor()

                // Keeps things from looking strange when user account is deleted
                if !AuthController.userIsLoggedOut() {
                    Form {
                        Section {
                            Button {
                                navigationViewModel.navigateToReauthenticationView()
                            } label: {
                                MockNavigationLinkRow(text: "Edit Account")
                            }
                            .tint(.primary)
                        }

                        Section {
                            Button("Log Out", role: .destructive) {
                                logOutConfirmationAlertIsShowing.toggle()
                            }
                            .alert(
                                "Are You Sure?",
                                isPresented: $logOutConfirmationAlertIsShowing,
                                actions: {
                                    Button("Cancel", role: .cancel) { }
                                    Button("Yes", role: .destructive) {
                                        dismiss()
                                        loggedInUserController.logOut()
                                    }
                                },
                                message: { Text("You will not be able to access your data on The Same Page until you log in again.") }
                            )
                        }
                    }
                    .navigationTitle("Profile Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                dismiss()
                            }
                        }
                    }
                    .navigationDestination(for: UserSettingsScreen.self) { userSettingsScreen in
                        switch userSettingsScreen {
                        case .reauthenticateView:
                            ReauthenticateView(navigationViewModel: navigationViewModel)
                        case .editUserInfoView:
                            EditUserInfoView(navigationViewModel: navigationViewModel)
                        case .changeEmailAddressView:
                            ChangeEmailAddressView(navigationViewModel: navigationViewModel)
                        case .changePasswordView:
                            ChangePasswordView(navigationViewModel: navigationViewModel)
                        case .deleteAccountView:
                            DeleteAccountView(navigationViewModel: navigationViewModel)
                        }
                    }
                }
            }
            .onAppear {
                if AuthController.userIsLoggedOut() {
                    dismiss()
                }
            }
        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}
