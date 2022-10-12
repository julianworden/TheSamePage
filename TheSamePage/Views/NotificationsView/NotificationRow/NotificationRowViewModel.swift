//
//  NotificationRowViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import Foundation

class NotificationRowViewModel: ObservableObject {
    enum NotificationRowViewModelError: Error {
        case unexpectedNilValue(message: String)
    }
    
    var notificationSender: String?
    var notificationBandName: String?
    var notificationShowName: String?
    var bandInvite: BandInvite?
    var showInvite: ShowInvite?
    
    init(bandInvite: BandInvite?, showInvite: ShowInvite?) {
        if let bandInvite {
            self.bandInvite = bandInvite
            self.notificationSender = bandInvite.senderName
            self.notificationBandName = bandInvite.senderBand
        } else if let showInvite {
            self.showInvite = showInvite
            self.notificationSender = showInvite.senderUsername
            self.notificationBandName = showInvite.bandName
            self.notificationShowName = showInvite.showName
        }
    }
    
    func acceptBandInvite() async throws {
        guard bandInvite != nil else { throw NotificationRowViewModelError.unexpectedNilValue(message: "bandInvite") }
        
        let username = try await AuthController.getLoggedInUsername()
        let fullName = try await AuthController.getLoggedInFullName()
        let bandMember = BandMember(uid: AuthController.getLoggedInUid(), role: bandInvite!.recipientRole, username: username, fullName: fullName)
        try await DatabaseService.shared.addUserToBand(add: bandMember, toBandWithId: bandInvite!.bandId, withBandInvite: bandInvite)
    }
    
    func acceptShowInvite() async throws {
        guard showInvite != nil else { throw NotificationRowViewModelError.unexpectedNilValue(message: "showInvite") }
        
        let showParticipant = ShowParticipant(name: showInvite!.bandName, bandId: showInvite!.bandId, showId: showInvite!.showId)
        
        try await DatabaseService.shared.addBandToShow(add: showParticipant, withShowInvite: showInvite!)
    }
    
    func declineBandInvite() async throws {
        guard bandInvite != nil else { return }
        
        try await DatabaseService.shared.deleteBandInvite(bandInvite: bandInvite!)
    }
    
    func declineShowInvite() async throws {
        guard showInvite != nil else { return }
        
        try await DatabaseService.shared.deleteShowInvite(showInvite: showInvite!)
    }
}
