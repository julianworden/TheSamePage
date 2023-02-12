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

    @ObservedObject var navigationViewModel: OnboardingNavigationViewModel

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
                            if navigationViewModel.navigationPath.count > 1 {
                                // User is onboarding
                                navigationViewModel.popToRoot()
                            } else {
                                // User is not onboarding
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
        CreateUsernameView(navigationViewModel: OnboardingNavigationViewModel())
    }
}
