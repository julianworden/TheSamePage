//
//  SendShowInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import Foundation

final class SendShowInviteViewModel: ObservableObject {
    var userShows = [Show]()
    var selectedShow: Show?
    
    /// The band that is being invited to join the show.
    let bandId: String
    let bandName: String
    var senderUsername: String?
    let recipientUid: String
    
    init(band: Band) {
        self.bandId = band.id ?? ""
        self.bandName = band.name
        self.recipientUid = band.adminUid
        Task {
            do {
                let username = try await AuthController.getLoggedInUsername()
                senderUsername = username
            } catch {
                print(error)
            }
        }
    }
    
    // TODO: Make DatabaseService Method for this
    func sendShowInviteNotification() throws {
        let showInvite = ShowInvite(
            recipientUid: recipientUid,
            bandName: bandName,
            bandId: bandId,
            showId: selectedShow?.id ?? "",
            showName: selectedShow?.name ?? "A Show",
            senderUsername: senderUsername ?? "A User"
        )
        
        try DatabaseService.shared.sendShowInvite(invite: showInvite)
    }
    
    func getHostedShows() async throws {
        userShows = try await DatabaseService.shared.getHostedShows()
        
        if !userShows.isEmpty {
            selectedShow = userShows.first!
        }
    }
}
