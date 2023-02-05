//
//  AnyBackline.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/4/23.
//

import Foundation

struct AnyBackline: Identifiable {
    let id: String
    let backline: any Backline

    var backlineType: BacklineItemType {
        let backlineTypeAsString = backline.type
        return BacklineItemType(rawValue: backlineTypeAsString)!
    }

    var loggedInUserIsBackliner: Bool {
        backline.loggedInUserIsBackliner
    }

    var iconName: String {
        switch backlineType {
        case .electricGuitar:
            return "electric guitar"
        case .bassGuitar:
            return "bass guitar"
        case .acousticGuitar:
            return "acoustic guitar"
        case .percussion:
            return "drums"
        }
    }
}
