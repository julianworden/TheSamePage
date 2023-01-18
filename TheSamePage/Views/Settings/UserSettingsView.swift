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
        
    var body: some View {
        NavigationView {
            Form {
                Button("Log Out", role: .destructive) {
                    loggedInUserController.logOut()
                    dismiss()
                }
            }
            .navigationTitle("Profile Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back", role: .cancel) {
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
