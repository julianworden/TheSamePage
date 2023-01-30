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
    @State private var createBandSheetIsShowing = false
    @State private var settingsButtonTapped = false

    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColor()
                
                ScrollView {
                    VStack {
                        LoggedInUserProfileHeader()

                        HStack {
                            SectionTitle(title: "Member of")
                        }

                        if !loggedInUserController.playingBands.isEmpty {
                            LoggedInUserBandList()

                            Button {
                                createBandSheetIsShowing.toggle()
                            } label: {
                                Label("Create Band", systemImage: "plus")
                            }
                            .buttonStyle(.bordered)
                            .fullScreenCover(
                                isPresented: $createBandSheetIsShowing,
                                onDismiss: {
                                    Task {
                                        await loggedInUserController.getLoggedInUserPlayingBands()
                                    }
                                },
                                content: {
                                    NavigationView {
                                        AddEditBandView(bandToEdit: nil, isPresentedModally: true)
                                    }
                                }
                            )
                        } else if loggedInUserController.playingBands.isEmpty {
                            NoDataFoundMessageWithButtonView(
                                isPresentingSheet: $createBandSheetIsShowing,
                                shouldDisplayButton: true,
                                buttonText: "Create Band",
                                buttonImageName: "plus",
                                message: "You are not a member of any bands"
                            )
                            .padding(.top)
                        }
                    }
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    NavigationLink(isActive: $settingsButtonTapped) {
                        UserSettingsView()
                            // These modifiers have to be here, not within the view, or else strange
                            // navigationTitle and list behavior in UserSettingsView will occur
                            .navigationTitle("Profile Settings")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .task {
                // Without this, UserSettingsView will still be present after a user
                // logs out and logs back in and navigates to the Profile tab.
                settingsButtonTapped = false
                await loggedInUserController.callOnAppLaunchMethods()
            }
        }
        // Without this, the search bar in MemberSearchView is not usable
        .navigationViewStyle(.stack)
    }
}

struct LoggedInUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserProfileView()
    }
}
