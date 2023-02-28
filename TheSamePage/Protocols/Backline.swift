//
//  Backline.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import FirebaseFirestoreSwift
import Foundation

protocol Backline: Codable {
    var id: String? { get }
    var backlinerUid: String { get }
    var backlinerFullName: String { get }
    var type: String { get }
    var name: String { get }
    var notes: String? { get }
    var loggedInUserIsBackliner: Bool { get }
}
