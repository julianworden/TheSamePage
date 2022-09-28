//
//  SendBandInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/25/22.
//

import FirebaseAuth
import Foundation

class SendBandInviteViewModel: ObservableObject {
    @Published var recipientRole = Instrument.vocals
    
    /// The user who will be receiving the band invite.
    let user: User
    /// The band that the user will be invited to join.
    let band: Band?
    
    init(user: User, band: Band?) {
        self.user = user
        self.band = band
    }
    
    func sendBandInviteNotification() throws {
        // TODO: Fix force unwrapping
        if band?.id != nil && user.id != nil {
            let invite = BandInvite(
                recipientUid: user.id!,
                recipientRole: recipientRole.rawValue,
                bandId: band!.id!,
                senderName: Auth.auth().currentUser!.email!,
                senderBand: band!.name
            )
            try DatabaseService.shared.sendBandInvite(invite: invite)
        }
    }
}
