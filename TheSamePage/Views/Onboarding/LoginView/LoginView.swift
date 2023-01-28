//
//  LoginView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import UIKit
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @StateObject var viewModel = LoginViewModel()
    
    @Binding var userIsOnboarding: Bool

    @State private var forgotPasswordSheetIsShowing = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email Address", text: $viewModel.emailAddress)
                    SecureField("Password", text: $viewModel.password)
                    AsyncButton {
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
                        NavigationView {
                            ForgotPasswordView()
                        }
                    }
                }

                Section("Don't have an account?") {
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Sign Up")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationTitle("Log In")
            .errorAlert(
                isPresented: $viewModel.loginErrorShowing,
                message: viewModel.loginErrorMessage
            )
            .onChange(of: viewModel.userIsOnboarding) { userIsOnboarding in
                if !userIsOnboarding {
                    self.userIsOnboarding = userIsOnboarding
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userIsOnboarding: .constant(true))
    }
}
