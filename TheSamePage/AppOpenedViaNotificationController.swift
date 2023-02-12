//
//  File.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/12/23.
//

import Foundation

class AppOpenedViaNotificationController: ObservableObject {
    @Published var appOpenedViaNewMessageNotification = false

    var chatId = ""

    init() {
        addAppOpenedViaNewMessageNotificationObserver()
    }

    func addAppOpenedViaNewMessageNotificationObserver() {
        NotificationCenter.default.addObserver(forName: .appOpenedViaNewMessageNotification, object: nil, queue: .main) { notification in
            if let chatId = notification.userInfo?[FbConstants.chatId] as? String {
                Task { @MainActor in
                    self.chatId = chatId
                    self.appOpenedViaNewMessageNotification.toggle()
                    print(chatId)
                }
            }
        }
    }
}
