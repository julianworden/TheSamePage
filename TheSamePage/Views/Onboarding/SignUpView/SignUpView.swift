//
//  SignUpView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject var viewModel = SignUpViewModel()

    @ObservedObject var navigationViewModel: OnboardingNavigationViewModel

    @FocusState private var textFieldIsFocused: Bool

    var body: some View {
        Form {
            Section {
                ImageSelectionButton(
                    imagePickerIsShowing: $viewModel.imagePickerIsShowing,
                    selectedImage: $viewModel.profileImage
                )
            } header: {
                Text("Profile Picture")
            } footer: {
                Text("Tap the camera icon to select a profile picture.")
            }

            Section {
                CustomTextField("Email Address", text: $viewModel.emailAddress, keyboardType: .emailAddress)
                    .focused($textFieldIsFocused)

                CustomTextField("Confirm Email Address", text: $viewModel.confirmedEmailAddress, keyboardType: .emailAddress)
                    .focused($textFieldIsFocused)
            } footer: {
                Text("Ensure you've entered a valid email address, you'll need to receive an email verification link after signing up.")
            }

            Section {
                SecureField("Password", text: $viewModel.password)
                    .focused($textFieldIsFocused)
                SecureField("Confirm Password", text: $viewModel.confirmedPassword)
                    .focused($textFieldIsFocused)
            }

            Section {
                TextField("First name", text: $viewModel.firstName)
                    .focused($textFieldIsFocused)
                    .autocorrectionDisabled()

                TextField("Last name", text: $viewModel.lastName)
                    .focused($textFieldIsFocused)
                    .autocorrectionDisabled()
            }

            Section {
                AsyncButton {
                    textFieldIsFocused = false
                    await viewModel.signUpButtonTapped()
                } label: {
                    Text("Create Profile")
                }
                .disabled(viewModel.signUpButtonIsDisabled)
                .alert(
                    "Success!",
                    isPresented: $viewModel.profileCreationWasSuccessful,
                    actions: {
                        Button("OK") { navigationViewModel.navigateToCreateUsernameView() }
                    },
                    message: { Text("An email verification link was sent to \(viewModel.emailAddress). You'll need to verify your email address before you can log in and use The Same Page.") }
                )
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.imagePickerIsShowing) {
            ImagePicker(image: $viewModel.profileImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView(navigationViewModel: OnboardingNavigationViewModel())
        }
    }
}
