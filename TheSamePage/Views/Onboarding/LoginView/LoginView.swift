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

    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
                AsyncButton {
                    await viewModel.userIsOnboardingAfterLoginWith(
                        emailAddress: viewModel.emailAddress,
                        password: viewModel.password
                    )
                } label: {
                    Text("Log In")
                }
                .disabled(viewModel.loginButtonIsDisabled)
                
                Text("Don't have an account?")
                NavigationLink {
                    SignUpView(userIsOnboarding: $userIsOnboarding)
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Log In")
            .alert(
                "Error",
                isPresented: $viewModel.loginErrorShowing,
                actions: {
                    Button("OK") { }
                },
                message: {
                    Text(viewModel.loginErrorMessage)
                }
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
