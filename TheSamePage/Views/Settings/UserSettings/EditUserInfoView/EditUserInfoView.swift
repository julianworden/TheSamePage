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

    @Binding var editAccountFlowIsActive: Bool

    var body: some View {
        Form {
            Section {
                NavigationLink {
                    EditEmailAddressView()
                } label: {
                    Text("Change Email Address")
                }

                NavigationLink {
                    ChangePasswordView()
                } label: {
                    Text("Change Password")
                }
            }

            Section {
                NavigationLink {
                    DeleteAccountView()
                } label: {
                    Text("Delete Account")
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    editAccountFlowIsActive = false
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }

    }
}

struct EditUserInfoView_Previews: PreviewProvider {
    static var previews: some View {
        EditUserInfoView(editAccountFlowIsActive: .constant(true))
    }
}
