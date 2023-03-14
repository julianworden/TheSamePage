//
//  Notification.Name+CustomNotifications.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/22/22.
//

import Foundation

extension Notification.Name {
    static let showAddressSelected = Notification.Name("showAddressSelected")
    static let deviceIsOffline = Notification.Name("deviceIsOffline")
    static let deviceIsOnline = Notification.Name("deviceIsOnline")
    static let userLocationWasSet = Notification.Name("userLocationWasSet")
    static let appOpenedViaNewMessageNotification = Notification.Name("appOpenedViaNewMessageNotification")
    static let appOpenedViaNewInviteOrApplicationNotification = Notification.Name("appOpenedViaNewInviteOrApplicationNotification")
    static let appOpenedViaBandNotificationOrDynamicLink = Notification.Name("appOpenedViaBandNotificationOrDynamicLink")
    static let appOpenedViaShowNotificationOrDynamicLink = Notification.Name("appOpenedViaShowNotificationOrDynamicLink")
    static let appOpenedViaUserDynamicLink = Notification.Name("appOpenedViaUserDynamicLink")
    static let didReceiveRegistrationToken = Notification.Name("didReceiveRegistrationToken")
}
