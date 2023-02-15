//
//  LoginView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import UIKit
import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var navigationViewModel = OnboardingNavigationViewModel()

    @State private var forgotPasswordSheetIsShowing = false

    @FocusState var keyboardIsFocused: Bool

    var body: some View {
        NavigationStack(path: $navigationViewModel.navigationPath) {
            Form {
                Section {
                    CustomTextField("Email Address", text: $viewModel.emailAddress, keyboardType: .emailAddress)
                        .focused($keyboardIsFocused)

                    SecureField("Password", text: $viewModel.password)
                        .focused($keyboardIsFocused)

                    AsyncButton {
                        keyboardIsFocused = false
                        await viewModel.logInUserWith(
                            emailAddress: viewModel.emailAddress,
                            password: viewModel.password
                        )
                    } label: {
                        Text("Log In")
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                    .alert(
                        "Error",
                        isPresented: $viewModel.unverifiedEmailErrorShowing,
                        actions: {
                            Button("OK") {
                                viewModel.logOutUser()
                                viewModel.buttonsAreDisabled = false
                            }

                            Button("Send New Verification Link") {
                                Task {
                                    await viewModel.sendEmailVerificationEmail()
                                    viewModel.logOutUser()
                                    viewModel.buttonsAreDisabled = false
                                }
                            }
                        },
                        message: { Text(viewModel.unverifiedEmailErrorText) }
                    )

                    Button("Forgot your password?") {
                        forgotPasswordSheetIsShowing.toggle()
                    }
                    .disabled(viewModel.buttonsAreDisabled)
                    .sheet(isPresented: $forgotPasswordSheetIsShowing) {
                        NavigationStack {
                            ForgotPasswordView()
                        }
                    }
                }
                .errorAlert(
                    isPresented: $viewModel.loginErrorShowing,
                    message: viewModel.loginErrorMessage
                )

                Section("Don't have an account?") {
                    ZStack(alignment: .leading) {
                        Button {
                            navigationViewModel.navigateToSignUpView()
                        } label: {
                            Text("Sign Up")
                        }
                        .disabled(viewModel.buttonsAreDisabled)
                    }
                }
            }
            .navigationTitle("Log In")
            .fullScreenCover(
                isPresented: $viewModel.createUsernameSheetIsShowing,
                onDismiss: {
                    Task {
                        if await viewModel.userHasUsername() {
                            dismiss()
                        } else {
                            viewModel.buttonsAreDisabled = false
                        }
                    }
                },
                content: {
                    NavigationStack {
                        CreateUsernameView(navigationViewModel: navigationViewModel)
                    }
                }
            )
            .alert(
                "Error",
                isPresented: $viewModel.currentUserHasNoUsernameAlertIsShowing,
                actions: {
                    Button("Create a Username") { viewModel.createUsernameSheetIsShowing = true }
                },
                message: { Text("You need a username to use The Same Page, but you have not set one up yet.") }
            )
            .navigationDestination(for: OnboardingScreen.self) { onboardingScreen in
                switch onboardingScreen {
                case .signUpView:
                    SignUpView(navigationViewModel: navigationViewModel)
                case .createUsernameView:
                    CreateUsernameView(navigationViewModel: navigationViewModel)
                }
            }
            .onChange(of: viewModel.userIsOnboarding) { userIsOnboarding in
                if !userIsOnboarding {
                    dismiss()
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
