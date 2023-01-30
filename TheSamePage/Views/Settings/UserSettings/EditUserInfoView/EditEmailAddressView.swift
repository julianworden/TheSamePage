//
//  EditEmailAddressView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct EditEmailAddressView: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    var body: some View {
        Button("test") {
            loggedInUserController.logOut()
        }
    }
}

struct EditEmailAddressView_Previews: PreviewProvider {
    static var previews: some View {
        EditEmailAddressView()
    }
}
