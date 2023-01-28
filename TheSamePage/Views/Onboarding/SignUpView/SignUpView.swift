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

    var body: some View {
        Form {
            Section("Account Info") {
                ImageSelectionButton(
                    imagePickerIsShowing: $viewModel.imagePickerIsShowing,
                    selectedImage: $viewModel.profileImage
                )
                // TODO: Move username field to another screen
                TextField("Username", text: $viewModel.username)
                    .textInputAutocapitalization(.never)
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
            }
            
            Section("Name") {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
            }
            
            Section {
                AsyncButton {
                    await viewModel.signUpButtonTapped()
                } label: {
                    Text("Create Profile")
                }
                .disabled(viewModel.signUpButtonIsDisabled)
                .alert(
                    "Success!",
                    isPresented: $viewModel.profileCreationWasSuccessful,
                    actions: {
                        Button("OK") { dismiss() }
                    },
                    message: { Text("Your account on The Same Page was successfully created! However, you'll need to click the email verification link that was sent to \(viewModel.emailAddress) before you can log in.") }
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
            SignUpView()
        }
    }
}
