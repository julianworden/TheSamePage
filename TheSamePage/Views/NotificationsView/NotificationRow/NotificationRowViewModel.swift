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
        
        // TODO: Make this show logged in user first and last name, not username
        let name = try await AuthController.getLoggedInUserName()
        let bandMember = BandMember(uid: AuthController.getLoggedInUid(), role: bandInvite!.recipientRole, name: name)
        let bandId = JoinedBand(id: bandInvite!.bandId)
        try DatabaseService.shared.addUserToBand(bandMember, addToBand: bandId, withBandInvite: bandInvite!)
    }
    
    func acceptShowInvite() async throws {
        guard showInvite != nil else { throw NotificationRowViewModelError.unexpectedNilValue(message: "showInvite") }
        
        try await DatabaseService.shared.addBandToShow(withShowInvite: showInvite!)
    }
    
    func declineBandInvite() {
        guard bandInvite != nil else { return }
        
        DatabaseService.shared.deleteBandInvite(bandInvite: bandInvite!)
    }
    
    func declineShowInvite() {
        guard showInvite != nil else { return }
        
        DatabaseService.shared.deleteShowInvite(showInvite: showInvite!)
    }
}
