//
//  ForgotPasswordView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/26/23.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = ForgotPasswordViewModel()

    var body: some View {
        Form {
            Section {
                TextField("Email Address", text: $viewModel.emailAddress)
                    .keyboardType(.emailAddress)
            } footer: {
                Text("Enter your email address. If an account exists with this email address, you will receive an email with instructions for resetting your password.")
            }
            Section {
                AsyncButton {
                    await viewModel.sendPasswordResetEmail()
                } label: {
                    Text("Send Email")
                }
                .disabled(viewModel.sendEmailButtonIsDisabled)
                .alert(
                    "Success!",
                    isPresented: $viewModel.successfullySentPasswordResetEmailAlertIsShowing,
                    actions: { Button("OK") { dismiss() } },
                    message: { Text(viewModel.successfullySentPasswordResetEmailAlertText) }
                )
            }
        }
        .navigationTitle("Password Reset")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
