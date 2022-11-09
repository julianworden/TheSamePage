//
//  LoggedInUserProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

/// Displayed to the user when they're viewing their own profile.
struct LoggedInUserProfileView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @Binding var userIsLoggedOut: Bool
    
    /// The image loaded from the ProfileAsyncImage
    @State private var userImage: Image?
    /// A new image set within EditImageView
    @State private var updatedImage: UIImage?
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if let loggedInUser = loggedInUserController.loggedInUser {
                ScrollView {
                    VStack {
                        NavigationLink {
                            EditImageView(user: loggedInUser, image: userImage, updatedImage: $updatedImage)
                        } label: {
                            if updatedImage == nil {
                                ProfileAsyncImage(url: URL(string: loggedInUserController.profileImageUrl ?? ""), loadedImage: $userImage)
                            } else {
                                Image(uiImage: updatedImage!)
                                    .resizable()
                                    .scaledToFit()
                                    .border(.white, width: 3)
                                    .frame(height: 200)
                                    .padding(.horizontal)
                            }
                        }
                        
                        HStack {
                            SectionTitle(title: "Member of")
                            
                            NavigationLink {
                                AddEditBandView(userIsOnboarding: .constant(false), bandToEdit: nil)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .padding(.trailing)
                        }
                        
                        LoggedInUserBandList()
                    }
                }
                .navigationTitle("\(loggedInUserController.firstName ?? "You") \(loggedInUserController.lastName ?? "")")
                .navigationBarTitleDisplayMode(.large)
            } else {
                ErrorMessage(
                    message: "Failed to fetch logged in user. Please check your internet connection and restart the app."
                )
            }
        }
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    UserSettingsView(userIsLoggedOut: $userIsLoggedOut)
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .onChange(of: userImage) { _ in }
        
        .onChange(of: updatedImage) { updatedImage in
            if let updatedImage {
                self.userImage = Image(uiImage: updatedImage)
                loggedInUserController.addUserListener()
            }
        }
        .onDisappear {
            loggedInUserController.removeUserListener()
        }
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView(userIsLoggedOut: .constant(false))
    }
}
