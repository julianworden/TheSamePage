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
            Section {
                Button {
                    imagePickerIsShowing = true
                } label: {
                    if let profileImage {
                        HStack {
                            Spacer()
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                            Spacer()
                        }
                    } else {
                        NoImageView()
                    }
                }
                TextField("Email Address", text: $viewModel.emailAddress)
                SecureField("Password", text: $viewModel.password)
            } header: {
                Text("Account Info")
            }

            Section {
                TextField("First name", text: $viewModel.firstName)
                TextField("Last name", text: $viewModel.lastName)
            } header: {
                Text("Name")
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
