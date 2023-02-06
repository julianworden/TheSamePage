//
//  ReauthenticateView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct ReauthenticateView: View {
    @StateObject private var viewModel = ReauthenticateViewModel()

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    @FocusState private var keyboardIsFocused: Bool

    var body: some View {
        Form {
            Section {
                CustomTextField("Email Address", text: $viewModel.emailAddress, keyboardType: .emailAddress)
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
                    if viewModel.reauthenticationSuccessful {
                        navigationViewModel.navigateToEditUserInfoView()
                    }
                } label: {
                    Text("Submit")
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
        ReauthenticateView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
