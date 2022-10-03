//
//  BandLinkCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/30/22.
//

import Foundation
import UIKit

class BandLinkCardViewModel: ObservableObject {
    let iconName: String
    
    init(link: PlatformLink) {
        self.iconName = link.platformName.lowercased()
    }
}
