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
    
    @Binding var userIsLoggedOut: Bool
    
    var hideNavigationLink = true
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
                Button {
                    Task {
                        do {
                            viewModel.loginButtonIsDisabled = true
                            try await viewModel.logInButtonTapped()
                            userIsLoggedOut = false
                        } catch {
                            viewModel.loginButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    Text("Log In")
                }
                .disabled(viewModel.loginButtonIsDisabled)
                
                Text("Don't have an account?")
                NavigationLink {
                    SignUpView(userIsLoggedOut: $userIsLoggedOut)
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
        LoginView(userIsLoggedOut: .constant(true))
    }
}
