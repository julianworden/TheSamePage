//
//  ProfileViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/18/22.
//

import FirebaseAuth
import Foundation

class UserProfileViewModel: ObservableObject {
    enum ProfileViewModelError: Error {
        case firebaseAuthError(message: String)
    }
    
    @Published var streamingActionSheetIsShowing = false
    
    /// The user being displayed. When this value is nil, the logged in user is viewing their own profile
    @Published var user: User?
    /// The band that the user will be invited to join if their invite button is tapped.
    @Published var band: Band?
    
    init(user: User? = nil, band: Band? = nil) {
        self.user = user
        self.band = band
    }
    
    func sendBandInviteNotification() throws {
        if user != nil {
            // TODO: Get rid of force unwrapping
            let invite = BandInvite(
                recipientUid: user!.id!,
                bandId: band!.id!,
                senderName: Auth.auth().currentUser!.email!,
                senderBand: band!.name
            )
            try DatabaseService.shared.sendBandInvite(invite: invite)
        }
    }
}
