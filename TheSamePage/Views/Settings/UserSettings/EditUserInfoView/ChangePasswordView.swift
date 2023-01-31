//
//  ChangePasswordView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/30/23.
//

import SwiftUI

struct ChangePasswordView: View {
    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
