//
//  ShowTimeType.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/12/22.
//

import Foundation

enum ShowTimeType: String, CaseIterable, Identifiable {
    case loadIn = "Load In"
    case musicStart = "Music Start"
    case end = "End"
    case doors = "Doors"
    
    var id: Self { self }
    
    var rowTitleText: String {
        switch self {
        case .loadIn:
            return "Load In:"
        case .musicStart:
            return "Music Start:"
        case .end:
            return "End:"
        case .doors:
            return "Doors:"
        }
    }
    
    var rowIconName: String {
        switch self {
        case .loadIn:
            return "loadIn"
        case .musicStart:
            return "musicStart"
        case .end:
            return "end"
        case .doors:
            return "doors"
        }
    }

    var fbFieldValueName: String {
        switch self {
        case .loadIn:
            return "loadInTime"
        case .musicStart:
            return "musicStartTime"
        case .end:
            return "endTime"
        case .doors:
            return "doorsTime"
        }
    }
}
