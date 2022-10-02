//
//  BandLinkCardViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/30/22.
//

import Foundation
import UIKit

class BandLinkCardViewModel: ObservableObject {
    @Published var iconName: String
    
    let linkUrl: String
    
    init(link: Link) {
        self.iconName = link.platformName.lowercased()
        self.linkUrl = link.url
    }
    
    func openLink() {
        if UIApplication.shared.canOpenURL(URL(string: linkUrl)!) {
            UIApplication.shared.open(URL(string: linkUrl)!)
        } else {
            print("Failed to open link")
        }
    }
}
