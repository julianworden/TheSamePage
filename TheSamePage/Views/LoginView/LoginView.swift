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
    
    @State private var loginWasSuccessful = false
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
                            try await viewModel.logIn()
                            userIsLoggedOut = false
                        } catch {
                            loginButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    Text("Log In")
                }
                .disabled(loginButtonIsDisabled)
                
                Text("Don't have an account?")
                NavigationLink {
                    
                } label: {
                    Text("Sign Up")
                        .foregroundColor(.accentColor)
                }
            }
            .navigationTitle("Log In")
            .navigationBarBackButtonHidden()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(userIsLoggedOut: .constant(true))
    }
}
