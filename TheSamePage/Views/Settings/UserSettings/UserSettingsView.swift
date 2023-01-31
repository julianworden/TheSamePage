//
//  UserSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import SwiftUI

struct UserSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @StateObject private var viewModel = UserSettingsViewModel()

    @State private var logOutConfirmationAlertIsShowing = false
    #warning("Replace this with a NavigationPath")
    @State private var editAccountFlowIsActive = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink(isActive: $editAccountFlowIsActive) {
                        ReauthenticateView(editAccountFlowIsActive: $editAccountFlowIsActive)
                    } label: {
                        Text("Edit Account")
                    }
                }

                Section {
                    Button("Log Out", role: .destructive) {
                        logOutConfirmationAlertIsShowing.toggle()
                    }
                    .alert(
                        "Are You Sure?",
                        isPresented: $logOutConfirmationAlertIsShowing,
                        actions: {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                editAccountFlowIsActive = false
                                loggedInUserController.logOut()
                            }
                        },
                        message: { Text("You will not be able to access your data on The Same Page until you log in again.") }
                    )
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}
