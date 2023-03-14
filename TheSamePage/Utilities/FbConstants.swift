//
//  firebaseConstants.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation

/// Names of various Firestore collections and fields.
struct FbConstants {
    // MARK: - Firestore collections and field names
    static let id = "id"
    static let bands = "bands"
    static let shows = "shows"
    static let users = "users"
    static let chats = "chats"
    static let messages = "messages"
    static let text = "text"
    static let notifications = "notifications"
    static let members = "members"
    static let fullName = "fullName"
    static let links = "links"
    static let participants = "participants"
    static let participantUids = "participantUids"
    static let memberUids = "memberUids"
    static let bandId = "bandId"
    static let bandIds = "bandIds"
    static let showId = "showId"
    static let uid = "uid"
    static let name = "name"
    static let username = "username"
    static let backlineItems = "backlineItems"
    static let profileImageUrl = "profileImageUrl"
    static let imageUrl = "imageUrl"
    static let emailAddress = "emailAddress"
    static let adminUid = "adminUid"
    static let hostUid = "hostUid"
    static let maxNumberOfBands = "maxNumberOfBands"
    static let setTime = "setTime"
    static let recipientFcmToken = "recipientFcmToken"
    static let message = "message"
    static let chatId = "chatId"
    static let openNotificationsTab = "openNotificationsTab"
    static let sentTimestamp = "sentTimestamp"
    static let fcmToken = "fcmToken"
    static let currentViewerUids = "currentViewerUids"
    static let mostRecentMessageText = "mostRecentMessageText"
    static let mostRecentMessageTimestamp = "mostRecentMessageTimestamp"
    static let upToDateParticipantUids = "upToDateParticipantUids"
    static let mostRecentMessageSenderUsername = "mostRecentMessageSenderUsername"
    static let participantUsernames = "participantUsernames"
    static let backlinerUid = "backlinerUid"
    static let recipientUid = "recipientUid"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let bandAdminUid = "bandAdminUid"

    // MARK: - Firebase Functions
    static let recursiveDelete = "recursiveDelete"
    static let notifyAcceptedBandInvite = "notifyAcceptedBandInvite"
    static let notifyAcceptedShowInvite = "notifyAcceptedShowInvite"
    static let notifyAcceptedShowApplication = "notifyAcceptedShowApplication"
    static let path = "path"
}
