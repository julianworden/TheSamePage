//
//  File.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/12/23.
//

import Foundation
import SwiftUI

@MainActor
class AppOpenedViaNotificationController: ObservableObject {
    @Published var presentSheet = false
    @Published var selectedRootViewTab = 0

    var sheetDestination = AppOpenedViaNotificationSheetNavigatorViewDestination.none {
        didSet {
            presentSheet.toggle()
        }
    }

    init() {
        addAppOpenedViaNewMessageNotificationObserver()
        addAppOpenedViaInviteOrApplicationNotificationObserver()
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .conversationView(let chatId):
            return ConversationView(chatId: chatId).eraseToAnyView()

        case .showDetailsView(let showId):
            return ShowDetailsView(show: nil, showId: showId).eraseToAnyView()

        case .bandProfileView(let bandId):
            return BandProfileView(band: nil, bandId: bandId).eraseToAnyView()

        default:
            return Text("Invalid Sheet Destination").eraseToAnyView()
        }
    }

    func addAppOpenedViaNewMessageNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaNewMessageNotification, object: nil, queue: .main) { notification in
            if let chatId = notification.userInfo?[FbConstants.chatId] as? String {
                Task { @MainActor in
                    self.sheetDestination = .conversationView(chatId: chatId)
                }
            }
        }
    }

    func addAppOpenedViaInviteOrApplicationNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaNewInviteOrApplicationNotification, object: nil, queue: .main) { notification in
            if let openNotificationsTab = notification.userInfo?[FbConstants.openNotificationsTab] as? String {
                if openNotificationsTab.isTrue {
                    Task { @MainActor in
                        self.selectedRootViewTab = 3
                    }
                }
            }
        }
    }
}
