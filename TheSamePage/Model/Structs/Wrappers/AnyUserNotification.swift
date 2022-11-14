//
//  AnyNotification.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/12/22.
//

import Foundation

/// A wrapper type that makes it possible to use a type conforming to the UserNotification protocol
/// in conjunction with a SwiftUI list.
struct AnyUserNotification: Identifiable {
    let id: String
    let notification: any UserNotification
}
