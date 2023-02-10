//
//  Date+CustomTimeFormat.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import Foundation

extension Date {
    var timeOmittedNumericDate: String {
        self.formatted(date: .numeric, time: .omitted)
    }

    var timeShortened: String {
        self.formatted(date: .omitted, time: .shortened)
    }
    
    var timeAndDate: String {
        self.formatted(date: .numeric, time: .shortened)
    }
}
