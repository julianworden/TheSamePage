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
    @Published var presentViewFromNotification = false
    @Published var appNotificationTapped = false
    @Published var selectedRootViewTab = 0

    var sheetDestination = AppOpenedViaNotificationSheetNavigatorViewDestination.none

    init() {
        addAppOpenedViaNewMessageNotificationObserver()
        addAppOpenedViaNewInviteOrApplicationNotificationObserver()
        addAppOpenedViaBandNotificationOrDynamicLinkObserver()
        addAppOpenedViaShowNotificationOrDynamicLinkObserver()
        addAppOpenedViaUserDynamicLinkObserver()
    }

    func sheetView() -> AnyView {
        switch sheetDestination {
        case .conversationView(let chatId):
            return ConversationView(chat: nil, chatId: chatId, isPresentedModally: true).eraseToAnyView()

        case .showDetailsView(let showId):
            return ShowDetailsView(show: nil, showId: showId, isPresentedModally: true).eraseToAnyView()

        case .bandProfileView(let bandId):
            return BandProfileView(band: nil, bandId: bandId, isPresentedModally: true).eraseToAnyView()

        case .otherUserProfileView(let uid):
            return OtherUserProfileView(user: nil, uid: uid, isPresentedModally: true).eraseToAnyView()

        default:
            return Text("Invalid Sheet Destination").eraseToAnyView()
        }
    }

    func addAppOpenedViaNewMessageNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaNewMessageNotification, object: nil, queue: .main) { notification in
            if let chatId = notification.userInfo?[FbConstants.chatId] as? String {
                Task { @MainActor in
                    self.appNotificationTapped.toggle()
                    self.sheetDestination = .conversationView(chatId: chatId)
                    self.presentViewFromNotification = true
                }
            }
        }
    }

    func addAppOpenedViaNewInviteOrApplicationNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaNewInviteOrApplicationNotification, object: nil, queue: .main) { notification in
            if let openNotificationsTab = notification.userInfo?[FbConstants.openNotificationsTab] as? String {
                if openNotificationsTab.isTrue {
                    Task { @MainActor in
                        self.presentViewFromNotification = false
                        self.appNotificationTapped.toggle()
                        self.selectedRootViewTab = 3
                    }
                }
            }
        }
    }

    func addAppOpenedViaBandNotificationOrDynamicLinkObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaBandNotificationOrDynamicLink, object: nil, queue: .main) { notification in
            if let bandId = notification.userInfo?[FbConstants.bandId] as? String {
                Task { @MainActor in
                    self.appNotificationTapped.toggle()
                    self.sheetDestination = .bandProfileView(bandId: bandId)
                    self.presentViewFromNotification = true
                }
            }
        }
    }

    func addAppOpenedViaShowNotificationOrDynamicLinkObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaShowNotificationOrDynamicLink, object: nil, queue: .main) { notification in
            if let showId = notification.userInfo?[FbConstants.showId] as? String {
                Task { @MainActor in
                    self.appNotificationTapped.toggle()
                    self.sheetDestination = .showDetailsView(showId: showId)
                    self.presentViewFromNotification = true
                }
            }
        }
    }

    func addAppOpenedViaUserDynamicLinkObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaUserDynamicLink, object: nil, queue: .main) { notification in
            if let uid = notification.userInfo?[FbConstants.uid] as? String {
                Task { @MainActor in
                    self.appNotificationTapped.toggle()
                    self.sheetDestination = .otherUserProfileView(uid: uid)
                    self.presentViewFromNotification = true
                }
            }
        }
    }
}
