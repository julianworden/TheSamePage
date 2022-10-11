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
            // TODO: Should call a different, not made yet DatabaseService method that finds all of the bands that the logged in user is an admin of
            let fetchedBands = try await DatabaseService.shared.getBands(withUid: AuthController.getLoggedInUid())
            userBands = fetchedBands.filter { $0.adminUid == AuthController.getLoggedInUid() }
            
            if !userBands.isEmpty {
                selectedBand = userBands.first!
            }
        }
    }
    
    func sendBandInviteNotification() throws {
        // TODO: Handle error
        if selectedBand != nil && selectedBand?.id != nil && user.id != nil {
            let invite = BandInvite(
                recipientUid: user.id!,
                recipientRole: recipientRole.rawValue,
                bandId: selectedBand!.id!,
                senderName: Auth.auth().currentUser!.email!,
                senderBand: selectedBand!.name
            )
            try DatabaseService.shared.sendBandInvite(invite: invite)
        }
    }
}
