//
//  CreateUsernameView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/27/23.
//

import SwiftUI

struct CreateUsernameView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel = CreateUsernameViewModel()

    @Binding var signUpFlowIsActive: Bool

    var body: some View {
        Form {
            Section {
                CustomTextField("Username", text: $viewModel.username)
            }

            Section {
                AsyncButton {
                    await viewModel.createUsername()
                } label: {
                    Text("Create Username")
                }
                .disabled(viewModel.createUsernameButtonIsDisabled)
                .alert(
                    "Success",
                    isPresented: $viewModel.usernameCreationWasSuccessfulAlertIsShowing,
                    actions: {
                        Button("OK") {
                            if signUpFlowIsActive {
                                signUpFlowIsActive.toggle()
                            } else {
                                dismiss()
                            }
                        }
                    },
                    message: { Text("Your username has been created successfully!") }
                )
            }
        }
        .navigationTitle("Create a Username")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
    }
}

struct CreateUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUsernameView(signUpFlowIsActive: .constant(true))
    }
}
