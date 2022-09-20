//
//  SignUpView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    
    @Binding var userIsLoggedOut: Bool
    
    @State private var signUpButtonIsDisabled = false
    
    var body: some View {
        Form {
            TextField("Email Address", text: $viewModel.emailAddress)
            SecureField("Password", text: $viewModel.password)
            Button {
                Task {
                    do {
                        signUpButtonIsDisabled = true
                        try await viewModel.createUserAccount()
                        userIsLoggedOut = false
                    } catch {
                        signUpButtonIsDisabled = false
                        print(error)
                    }
                }
            } label: {
                Text("Sign Up")
            }
            .disabled(signUpButtonIsDisabled)
        }
        .navigationTitle("Sign Up")
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(userIsLoggedOut: .constant(true))
    }
}
