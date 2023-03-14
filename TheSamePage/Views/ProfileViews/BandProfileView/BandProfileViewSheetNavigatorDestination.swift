//
//  BandProfileViewSheetNavigatorDestination.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/21/23.
//

import Foundation

enum BandProfileViewSheetNavigatorDestination {
    case bandSettingsView(band: Band)
    case sendShowInviteView(band: Band)
    case none
}
