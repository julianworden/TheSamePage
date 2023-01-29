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

    @Binding var signUpFlowIsActive: Bool

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
                TextField("Email Address", text: $viewModel.emailAddress)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .focused($textFieldIsFocused)
                TextField("Confirm Email Address", text: $viewModel.confirmedEmailAddress)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
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
                TextField("Last name", text: $viewModel.lastName)
                    .focused($textFieldIsFocused)
            }

            Section {
                AsyncButton {
                    textFieldIsFocused = false
                    await viewModel.signUpButtonTapped()
                } label: {
                    NavigationLink(
                        destination: CreateUsernameView(signUpFlowIsActive: $signUpFlowIsActive),
                        isActive: $viewModel.presentCreateUsernameView,
                        label: {
                            Text("Create Profile")
                        }
                    )
                }
                .disabled(viewModel.signUpButtonIsDisabled)
                .alert(
                    "Success!",
                    isPresented: $viewModel.profileCreationWasSuccessful,
                    actions: {
                        Button("OK") { viewModel.presentCreateUsernameView.toggle() }
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
        NavigationView {
            SignUpView(signUpFlowIsActive: .constant(true))
        }
    }
}
