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

    var details: String {
        if let drumKitBacklineItem = backline as? DrumKitBacklineItem {
            return "\(drumKitBacklineItem.notes ?? "")\(drumKitBacklineItem.notes == nil ?  drumKitBacklineItem.includedKitPiecesFormattedList : " \(drumKitBacklineItem.includedKitPiecesFormattedList)")"
        } else if let backlineItem = backline as? BacklineItem {
            return backlineItem.notes ?? ""
        } else {
            return ""
        }
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
        case .stageGear:
            return "stage"
        case .keys:
            return "keys"
        }
    }
}
