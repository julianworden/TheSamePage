//
//  SendShowInviteViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import Foundation

@MainActor
final class SendShowInviteViewModel: ObservableObject {
    @Published var state = ViewState.dataLoading
    
    var userShows = [Show]()
    @Published var selectedShow: Show?
    
    /// The band that is being invited to join the show.
    let bandId: String
    let bandName: String
    var senderUsername: String?
    let recipientUid: String
    
    @Published var invalidInviteAlertIsShowing = false
    @Published var invalidInviteAlertText = ""
    @Published var errorAlertIsShowing = false
    @Published var errorAlertText = ""
    
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
    
    func sendShowInviteNotification() async {
        let showInvite = ShowInvite(
            notificationType: NotificationType.showInvite.rawValue,
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
            is21Plus: selectedShow!.is21Plus,
            message: "\(senderUsername ?? "Someone") is inviting \(bandName) to play \(selectedShow!.name) at \(selectedShow!.venue) on \(selectedShow!.formattedDate)"
        )
        
        guard !selectedShow!.bandIds.contains(showInvite.bandId) else {
            invalidInviteAlertText = "This band is already playing this show."
            invalidInviteAlertIsShowing = true
            return
        }
        
        guard !selectedShow!.lineupIsFull else {
            invalidInviteAlertText = "This show's lineup is full. To invite this band, either increase the show's max number of bands or remove a band from the show's lineup."
            invalidInviteAlertIsShowing = true
            return
        }
            
        do {
            try DatabaseService.shared.sendShowInvite(invite: showInvite)
        } catch {
            errorAlertText = error.localizedDescription
            errorAlertIsShowing = true
        }
    }
    
    func getHostedShows() async {
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
            errorAlertText = error.localizedDescription
            errorAlertIsShowing = true
        }
    }
}
