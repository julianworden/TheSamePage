//
//  LoggedInUserProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct LoggedInUserProfileView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @Binding var userIsLoggedOut: Bool
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if loggedInUserController.loggedInUser != nil {
                ScrollView {
                    VStack {
                        ProfileAsyncImage(url: URL(string: loggedInUserController.profileImageUrl ?? ""), loadedImage: .constant(nil))
                        
                        HStack {
                            SectionTitle(title: "Member of")
                            
                            NavigationLink {
                                AddEditBandView(userIsOnboarding: .constant(false), bandToEdit: nil)
                            } label: {
                                Image(systemName: "plus")
                            }
                            .padding(.trailing)
                        }
                        
                        UserBandList(bands: loggedInUserController.bands)
                    }
                }
                .navigationTitle("\(loggedInUserController.firstName ?? "You") \(loggedInUserController.lastName ?? "")")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem {
                        NavigationLink {
                            UserSettingsView(userIsLoggedOut: $userIsLoggedOut)
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ErrorMessage(
                    message: "Failed to fetch logged in user. Please check your internet connection and restart the app."
                )
            }
        }
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView(userIsLoggedOut: .constant(false))
    }
}
