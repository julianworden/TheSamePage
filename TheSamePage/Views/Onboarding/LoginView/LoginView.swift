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

    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @StateObject var viewModel = LoginViewModel()

    @State private var forgotPasswordSheetIsShowing = false
    /// A property that's passed to views involved in signing up a new user for the app. This property
    /// enables CreateUsernameView to pop back to LoginView after a user has created a username successfully
    @State private var signUpFlowIsActive = false

    @FocusState var keyboardIsFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Email Address", text: $viewModel.emailAddress)
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
                    .disabled(viewModel.logInButtonIsDisabled)
                    .alert(
                        "Error",
                        isPresented: $viewModel.unverifiedEmailErrorShowing,
                        actions: {
                            Button("OK") {
                                viewModel.logOutUser()
                                viewModel.logInButtonIsDisabled = false
                            }

                            Button("Send New Verification Link") {
                                Task {
                                    await viewModel.sendEmailVerificationEmail()
                                    viewModel.logOutUser()
                                    viewModel.logInButtonIsDisabled = false
                                }
                            }
                        },
                        message: { Text(viewModel.unverifiedEmailErrorText) }
                    )

                    Button("Forgot your password?") {
                        forgotPasswordSheetIsShowing.toggle()
                    }
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
                    NavigationLink(isActive: $signUpFlowIsActive) {
                        SignUpView(signUpFlowIsActive: $signUpFlowIsActive)
                    } label: {
                        Text("Sign Up")
                            .foregroundColor(.accentColor)
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
                            viewModel.logInButtonIsDisabled = false
                        }
                    }
                },
                content: {
                    NavigationStack {
                        CreateUsernameView(signUpFlowIsActive: .constant(false))
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
