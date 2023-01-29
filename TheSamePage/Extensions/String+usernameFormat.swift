//
//  String+usernameFormat.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/28/23.
//

import Foundation

extension String {
    /// A convenience property that returns  a new string with no spaces or new lines.
    var lowercasedAndTrimmed: String {
        return self.lowercased().trimmed
    }
}
