//
//  TextUtility.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/16/22.
//

import Foundation

struct TextUtility {
    // TODO: Use .formatted() methods for these things instead
    static func formatDate(unixDate: Double) -> String {
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: unixDate)
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    static func formatTime(time: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let timeString = dateFormatter.string(from: time)
        return timeString
    }
}
