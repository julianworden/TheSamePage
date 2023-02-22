//
//  BandProfileViewSheetNavigator.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import Foundation
import SwiftUI

@MainActor
final class OtherUserProfileViewSheetNavigator: ObservableObject {
    @Published var presentSheet = false
    @Published var sheetDestination = OtherUserProfileViewSheetNavigatorDestination.none {
        didSet {
            presentSheet = true
        }
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .conversationView(let uid):
            return ConversationView(userId: uid, chatParticipantUids: [AuthController.getLoggedInUid(), uid]).eraseToAnyView()
            
        case .sendBandInvite(let user):
            return SendBandInviteView(user: user).eraseToAnyView()
            
        default:
            return Text("Invalid sheetDestination: \(String(describing: sheetDestination))").eraseToAnyView()
        }
    }
}
