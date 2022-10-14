//
//  Date+CustomTimeFormat.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/13/22.
//

import Foundation

extension Date {
    var timeShortened: String {
        self.formatted(date: .omitted, time: .shortened)
    }
}
