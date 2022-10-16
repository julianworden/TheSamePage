//
//  SendShowInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import Foundation

final class SendShowInviteViewModel: ObservableObject {
    enum SendShowInviteViewModelError: Error {
        case unexpectedNilValue(message: String)
    }
    
    @Published var state = ViewState.dataLoading
    
    var userShows = [Show]()
    var selectedShow: Show?
    
    /// The band that is being invited to join the show.
    let bandId: String
    let bandName: String
    var senderUsername: String?
    let recipientUid: String
    
    init(band: Band) {
        self.bandId = band.id
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
        guard selectedShow != nil else {
            throw SendShowInviteViewModelError.unexpectedNilValue(message: "selectedShow in sendShowInviteNotification()")
        }
        
        let showInvite = ShowInvite(
            recipientUid: recipientUid,
            bandName: bandName,
            bandId: bandId,
            showId: selectedShow!.id,
            showName: selectedShow!.name,
            showDate: selectedShow!.formattedDate,
            showVenue: selectedShow!.venue,
            senderUsername: senderUsername ?? "A User",
            hasFood: selectedShow!.hasFood,
            hasBar: selectedShow!.hasBar,
            is21Plus: selectedShow!.is21Plus
        )
        
        try DatabaseService.shared.sendShowInvite(invite: showInvite)
    }
    
    @MainActor
    func getHostedShows() async throws {
        state = .dataLoading
        
        do {
            userShows = try await DatabaseService.shared.getHostedShows()
            
            if !userShows.isEmpty {
                state = .dataLoaded
                selectedShow = userShows.first!
            } else {
                state = .dataNotFound
            }
        } catch {
            throw error
        }
    }
}
