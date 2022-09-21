//
//  SignUpView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    
    @Binding var userIsLoggedOut: Bool
    
    @State private var profileImage: UIImage?
    @State private var imagePickerIsShowing = false
    
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
            
            Section("Your band") {
                Toggle("Are you in a band?", isOn: $viewModel.userIsInABand)
                if viewModel.userIsInABand {
                    NavigationLink {
                        AddEditBandView()
                    } label: {
                        Text("Create a band profile")
                    }
                }
            }
            
            Section {
                Button("Create Profile") {
                    Task {
                        do {
                            viewModel.signUpButtonIsDisabled = true
                            try await viewModel.registerUser(withImage: profileImage)
                            userIsLoggedOut = false
                        } catch {
                            viewModel.signUpButtonIsDisabled = false
                            print(error)
                        }
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
            SignUpView(userIsLoggedOut: .constant(true))
        }
    }
}
