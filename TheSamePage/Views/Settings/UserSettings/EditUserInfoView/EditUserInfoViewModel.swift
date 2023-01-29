//
//  EditUserInfoViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/29/23.
//

import Foundation

@MainActor
final class EditUserInfoViewModel: ObservableObject {
    @Published var changePasswordSheetIsShowing = false
    @Published var changeEmailAddressSheetIsShowing = false
    @Published var changeUsernameSheetIsShowing = false
    @Published var deleteAccountConfirmationAlertIsShowing = false
}
