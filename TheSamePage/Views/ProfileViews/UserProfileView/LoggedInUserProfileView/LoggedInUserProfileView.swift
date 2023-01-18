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

    @State private var settingsSheetIsShowing = false

    @Binding var userIsLoggedOut: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColor()
                
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
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    Button {
                        settingsSheetIsShowing.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    .fullScreenCover(
                        isPresented: $settingsSheetIsShowing,
                        onDismiss: {
                            if loggedInUserController.loggedInUser == nil {
                                userIsLoggedOut = true
                            }
                        },
                        content: {
                            UserSettingsView()
                        }
                    )
                }
            }
            .errorAlert(
                isPresented: $loggedInUserController.errorMessageShowing,
                message: loggedInUserController.errorMessageText,
                tryAgainAction: {
                    await loggedInUserController.getLoggedInUserInfo()
                }
            )
            .task {
                await loggedInUserController.getLoggedInUserInfo()
            }
        }
        // Without this, the search bar in MemberSearchView is not usable
        .navigationViewStyle(.stack)
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView(userIsLoggedOut: .constant(false))
    }
}
