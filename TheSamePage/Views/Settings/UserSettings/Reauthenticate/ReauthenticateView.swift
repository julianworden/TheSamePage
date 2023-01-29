//
//  ReauthenticateView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct ReauthenticateView: View {
    @StateObject private var viewModel = ReauthenticateViewModel()

    @Binding var editAccountFlowIsActive: Bool

    @FocusState private var keyboardIsFocused: Bool

    var body: some View {
        Form {
            Section {
                TextField("Email Address", text: $viewModel.emailAddress)
                    .focused($keyboardIsFocused)

                SecureField("Password", text: $viewModel.password)
                    .focused($keyboardIsFocused)
            } footer: {
                Text("You'll need to confirm your account info before you can make changes to your account.")
            }

            Section {
                AsyncButton {
                    keyboardIsFocused = false
                    await viewModel.reauthenticateUser()
                } label: {
                    NavigationLink(
                        "Submit",
                        destination: EditUserInfoView(editAccountFlowIsActive: $editAccountFlowIsActive),
                        isActive: $viewModel.reauthenticationSuccessful
                    )
                }
                .disabled(viewModel.submitButtonIsDisabled)
            }
        }
        .navigationTitle("Confirm Account Info")
        .navigationBarTitleDisplayMode(.inline)
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
    }
}

struct ReauthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        ReauthenticateView(editAccountFlowIsActive: .constant(true))
    }
}
