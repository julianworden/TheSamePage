//
//  SignUpView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    
    @Binding var userIsOnboarding: Bool
    
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
                Toggle("Are affiliated with a band?", isOn: $viewModel.userIsInABand)
            }
            
            Section {
                AsyncButton {
                    await viewModel.signUpButtonTapped()
                } label: {
                    NavigationLink(
                        destination: InABandView(userIsOnboarding: $userIsOnboarding),
                        isActive: $viewModel.profileCreationWasSuccessful,
                        label: {
                            Text("Create Profile")
                        }
                    )
                }
                .disabled(viewModel.signUpButtonIsDisabled)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: viewModel.userIsInABand)
        .sheet(isPresented: $viewModel.imagePickerIsShowing) {
            ImagePicker(image: $viewModel.profileImage, pickerIsShowing: $viewModel.imagePickerIsShowing)
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .onChange(of: viewModel.userIsOnboarding) { userIsOnboarding in
            if !userIsOnboarding {
                self.userIsOnboarding = userIsOnboarding
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignUpView(userIsOnboarding: .constant(true))
        }
    }
}
