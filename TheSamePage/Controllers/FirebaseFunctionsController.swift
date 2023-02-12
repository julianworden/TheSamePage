//
//  FirebaseFunctionsController.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/10/23.
//

import FirebaseFunctions
import Foundation

struct FirebaseFunctionsController {
    static func recursiveDelete(path: String) async throws {
        _ = try await Functions.functions().httpsCallable(FbConstants.recursiveDelete).call([FbConstants.path: path])
    }

    static func notifyAcceptedBandInvite(
        recipientFcmToken: String,
        message: String,
        bandId: String
    ) async throws {
        _ = try await Functions.functions().httpsCallable(FbConstants.notifyAcceptedBandInvite).call(
            [
                FbConstants.recipientFcmToken: recipientFcmToken,
                FbConstants.message: message,
                FbConstants.bandId: bandId
            ]
        )
    }

    static func notifyAcceptedShowInvite(
        recipientFcmToken: String,
        message: String
    ) async throws {
        _ = try await Functions.functions().httpsCallable(FbConstants.notifyAcceptedShowInvite).call(
            [
                FbConstants.recipientFcmToken: recipientFcmToken,
                FbConstants.message: message
            ]
        )
    }

    static func notifyAcceptedShowApplication(
        recipientFcmToken: String,
        message: String
    ) async throws {
        _ = try await Functions.functions().httpsCallable(FbConstants.notifyAcceptedShowApplication).call(
            [
                FbConstants.recipientFcmToken: recipientFcmToken,
                FbConstants.message: message
            ]
        )
    }
}
