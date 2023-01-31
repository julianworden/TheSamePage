//
//  EditEmailAddressView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct ChangeEmailAddressView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    var body: some View {
        Button("test") {
            loggedInUserController.logOut()
        }
    }
}

struct EditEmailAddressView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEmailAddressView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
