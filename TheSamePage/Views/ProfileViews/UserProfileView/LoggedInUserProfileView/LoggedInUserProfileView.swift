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

    @StateObject private var sheetNavigator = LoggedInUserProfileViewSheetNavigator()

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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let shortenedDynamicLink = loggedInUserController.shortenedDynamicLink {
                            ShareLink(item: ".\(shortenedDynamicLink.absoluteString)") {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }

                        Button {
                            sheetNavigator.sheetDestination = .userSettingsView
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        EllipsesMenuIcon()
                    }
                    .fullScreenCover(isPresented: $sheetNavigator.presentSheet) {
                        sheetNavigator.sheetView()
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
