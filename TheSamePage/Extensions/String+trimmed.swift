//
//  String+trimmed.swift
//  TheSamePage
//
//  Created by Julian Worden on 1/27/23.
//

import Foundation

extension String {
    /// A cleaner way of writing trimmingCharacters(in: .whitespacesAndNewlines).
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
