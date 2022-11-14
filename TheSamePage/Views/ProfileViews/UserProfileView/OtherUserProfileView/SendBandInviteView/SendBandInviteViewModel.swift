//
//  SendBandInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/25/22.
//

import FirebaseAuth
import Foundation

final class SendBandInviteViewModel: ObservableObject {
    var userBands = [Band]()
    /// The band that the user will be invited to join.
    @Published var selectedBand: Band?
    @Published var recipientRole = Instrument.vocals
    
    /// The user who will be receiving the band invite.
    let user: User
    
    init(user: User) {
        self.user = user
        
        Task {
            do {
                try await getLoggedInUserBands()
            } catch {
                print(error)
            }
        }
    }
    
    @MainActor
    func getLoggedInUserBands() async throws {
        do {
            let fetchedBands = try await DatabaseService.shared.getBands(withUid: AuthController.getLoggedInUid())
            userBands = fetchedBands.filter { $0.adminUid == AuthController.getLoggedInUid() }
            
            if !userBands.isEmpty {
                selectedBand = userBands.first!
            }
        }
    }
    
    func sendBandInviteNotification() throws {
        let senderUsername = Auth.auth().currentUser!.email!
        
        // TODO: Handle error
        if selectedBand != nil {
            let invite = BandInvite(
                notificationType: NotificationType.bandInvite.rawValue,
                recipientUid: user.id,
                recipientRole: recipientRole.rawValue,
                bandId: selectedBand!.id,
                senderUsername: senderUsername,
                senderBand: selectedBand!.name,
                message: "\(senderUsername) is inviting you to join \(selectedBand!.name)"
            )
            try DatabaseService.shared.sendBandInvite(invite: invite)
        }
    }
}
