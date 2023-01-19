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
    @State private var createBandSheetIsShowing = false

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
                                        AddEditBandView(userIsOnboarding: .constant(false), bandToEdit: nil, isPresentedModally: true)
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
                    await loggedInUserController.callOnAppLaunchMethods()
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
        LoggedInUserProfileView(userIsLoggedOut: .constant(false))
    }
}
