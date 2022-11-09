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
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if loggedInUserController.loggedInUser != nil {
                ScrollView {
                    VStack {
                        LoggedInUserProfileHeader()
                        
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
                .navigationTitle("Your Profile")
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
