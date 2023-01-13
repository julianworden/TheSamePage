//
//  Double+UnixDateAsDate.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/12/23.
//

import Foundation

extension Double {
    var unixDateAsDate: Date {
        return Date(timeIntervalSince1970: self)
    }
}
