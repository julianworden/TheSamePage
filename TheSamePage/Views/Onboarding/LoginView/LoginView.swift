//
//  LoginView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import UIKit
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    @Binding var userIsOnboarding: Bool
    
    @State private var loginButtonIsDisabled = false
    
    var hideNavigationLink = true
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
                Button {
                    Task {
                        do {
                            loginButtonIsDisabled = true
                            try await viewModel.logInButtonTapped()
                            userIsOnboarding = false
                        } catch {
                            loginButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    AsyncButtonLabel(buttonIsDisabled: $loginButtonIsDisabled, title: "Log In")
                }
                .disabled(loginButtonIsDisabled)
                
                Text("Don't have an account?")
                NavigationLink {
                    SignUpView(userIsOnboarding: $userIsOnboarding)
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Log In")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userIsOnboarding: .constant(true))
    }
}
