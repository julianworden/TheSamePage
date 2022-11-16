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
    
    
    
    var hideNavigationLink = true
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
                Button {
                    Task {
                        do {
//                            viewModel.loginButtonIsDisabled = true
                            try await viewModel.logInButtonTapped(emailAddress: viewModel.emailAddress, password: viewModel.password)
                            //                    loggedInUserController.getLoggedInUserInfo()
                            userIsOnboarding = false
                        } catch {
                            print("Failed")
                        }
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $viewModel.loginButtonIsDisabled, title: "Log In")
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
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userIsOnboarding: .constant(true))
    }
}
