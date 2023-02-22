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

    @State private var errorAlertIsShowing = false
    @State private var errorAlertText = ""
    @State private var settingsButtonTapped = false
    @State private var selectedTab = SelectedUserProfileTab.bands

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack {
                        LoggedInUserProfileHeader()

                        Picker("Select a tab", selection: $selectedTab) {
                            ForEach(SelectedUserProfileTab.allCases) { tab in
                                Text(tab.rawValue)
                            }
                        }
                        .pickerStyle(.segmented)

                        switch selectedTab {
                        case .bands:
                            LoggedInUserBandsTab()
                        case .shows:
                            LoggedInUserShowsTab()
                        }
                    }
                    .padding(.horizontal)
                }
                .refreshable {
                    await loggedInUserController.callOnAppLaunchMethods()
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                #warning("Add sharing for your own profile")

                ToolbarItem {
                    Button {
                        settingsButtonTapped.toggle()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .fullScreenCover(
                isPresented: $settingsButtonTapped,
                onDismiss: {
                    if AuthController.userIsLoggedOut() {
                        loggedInUserController.currentUserIsInvalid = true
                    }
                },
                content: {
                    UserSettingsView()
                }
            )
            .task {
                // Without this, UserSettingsView will still be present after a user
                // logs out and logs back in and navigates to the Profile tab.
                settingsButtonTapped = false
            }
        }
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView()
    }
}
