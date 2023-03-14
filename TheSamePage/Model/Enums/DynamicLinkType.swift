//
//  DynamicLinkType.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/20/23.
//

import Foundation

enum DynamicLinkType: Codable {
    case show
    case band
    case user

    var queryItemName: String {
        switch self {
        case .show:
            return FbConstants.showId
        case .band:
            return FbConstants.bandId
        case .user:
            return FbConstants.uid
        }
    }
}
