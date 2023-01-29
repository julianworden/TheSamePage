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

                        if !loggedInUserController.bands.isEmpty {
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
                                        await loggedInUserController.getLoggedInUserBands()
                                    }
                                },
                                content: {
                                    NavigationView {
                                        AddEditBandView(bandToEdit: nil, isPresentedModally: true)
                                    }
                                }
                            )
                        } else if loggedInUserController.bands.isEmpty {
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
                    NavigationLink {
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
            .errorAlert(
                isPresented: $loggedInUserController.errorMessageShowing,
                message: loggedInUserController.errorMessageText,
                tryAgainAction: {
                    loggedInUserController.currentUserIsInvalid = true
                }
            )
            .task {
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
