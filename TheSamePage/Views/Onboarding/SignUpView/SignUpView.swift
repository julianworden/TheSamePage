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
    
    @State private var profileImage: UIImage?
    @State private var imagePickerIsShowing = false
    @State private var profileCreationWasSuccessful = false
    
    var body: some View {
        Form {
            Section("Account Info") {
                ImageSelectionButton(imagePickerIsShowing: $imagePickerIsShowing, selectedImage: $profileImage)
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
            }
            
            Section("Name") {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
            }
            
            Section {
                Toggle("Are you in a band?", isOn: $viewModel.userIsInABand)
            }
            
            Section {
                Button {
                    Task {
                        do {
                            viewModel.signUpButtonIsDisabled = true
                            try await viewModel.registerUser(withImage: profileImage)
                            
                            if viewModel.userIsInABand {
                                // Segue to InABandView
                                profileCreationWasSuccessful = true
                            } else {
                                userIsOnboarding = false
                            }
                        } catch {
                            viewModel.signUpButtonIsDisabled = false
                            print(error)
                        }
                    }
                } label: {
                    NavigationLink(destination: InABandView(userIsOnboarding: $userIsOnboarding), isActive: $profileCreationWasSuccessful) {
                        Text("Create Profile")
                    }
                }
                .disabled(viewModel.signUpButtonIsDisabled)
            }
        }
        .navigationTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: viewModel.userIsInABand)
        .sheet(isPresented: $imagePickerIsShowing) {
            ImagePicker(image: $profileImage, pickerIsShowing: $imagePickerIsShowing)
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
