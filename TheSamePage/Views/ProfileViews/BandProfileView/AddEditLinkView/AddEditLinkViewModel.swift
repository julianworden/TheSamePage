//
//  AddLinkViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation

class AddEditLinkViewModel: ObservableObject {
    @Published var linkPlatform = LinkPlatform.instagram
    @Published var enteredText = ""
    
    var link: Link?
    let band: Band
    var linkUrl = ""
    
    init(link: Link?, band: Band) {
        self.band = band
        
        if let link {
            self.linkPlatform = link.platformNameAsLinkPlatformObject
            self.linkUrl = link.url
            self.link = link
        }
    }
    
    func createLink() {
        switch linkPlatform {
        case .spotify:
            linkUrl = enteredText.lowercased()
        case .instagram:
            linkUrl = linkPlatform.urlPrefix + enteredText.lowercased()
        case .facebook:
            linkUrl = linkPlatform.urlPrefix + enteredText.lowercased() + "/posts/?ref=page_internal"
        case .none:
            break
        }
    }
    
    func uploadBandLink() throws {
        let newLink = Link(platformName: linkPlatform.rawValue, url: linkUrl)
        print(newLink.url)
        
        try DatabaseService.shared.uploadBandLink(withLink: newLink, forBand: band)
    }
}
