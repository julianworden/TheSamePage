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
                Button("Change Email Address") {
                    viewModel.changeEmailAddressSheetIsShowing.toggle()
                }

                Button("Change Password") {
                    viewModel.changePasswordSheetIsShowing.toggle()
                }

                Button("Change Username") {
                    viewModel.changeUsernameSheetIsShowing.toggle()
                }
            }

            Section {
                Button("Delete Account", role: .destructive) {
                    viewModel.deleteAccountConfirmationAlertIsShowing.toggle()
                }
                .alert(
                    "Are You Sure?",
                    isPresented: $viewModel.deleteAccountConfirmationAlertIsShowing,
                    actions: {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) { }
                    }
                )
                #warning("Make the yes button above delete the account")
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
