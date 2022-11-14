//
//  UserSettingsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/17/22.
//

import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    @Binding var userIsLoggedOut: Bool
    
    var body: some View {
        Form {
            Button("Log Out", role: .destructive) {
                userIsLoggedOut = true
                do {
                    try loggedInUserController.logOut()
                } catch {
                    print(error)
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
    
    struct UserSettingsView_Previews: PreviewProvider {
        static var previews: some View {
            UserSettingsView(userIsLoggedOut: .constant(false))
        }
    }
