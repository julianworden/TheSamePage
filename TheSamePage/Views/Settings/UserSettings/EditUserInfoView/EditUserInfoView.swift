//
//  EditUserInfoView.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import SwiftUI

struct EditUserInfoView: View {
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @StateObject private var viewModel = EditUserInfoViewModel()

    @ObservedObject var navigationViewModel: UserSettingsNavigationViewModel

    var body: some View {
        Form {
            Section {
                Button {
                    navigationViewModel.navigateToChangeEmailAddressView()
                } label: {
                    MockNavigationLinkRow(text: "Change Email Address")
                }

                Button {
                    navigationViewModel.navigateToChangePasswordView()
                } label: {
                    MockNavigationLinkRow(text: "Change Password")
                }
            }
            .tint(.primary)

            Section {
                Button(role: .destructive) {
                    navigationViewModel.navigateToDeleteAccountView()
                } label: {
                    MockNavigationLinkRow(text: "Delete Account", chevronColor: .red)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navigationViewModel.popToRoot()
                } label: {
                    MockBackButton()
                }
            }
        }

    }
}

struct EditUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserInfoView(navigationViewModel: UserSettingsNavigationViewModel())
    }
}
