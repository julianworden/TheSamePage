//
//  AddLinkViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/29/22.
//

import Foundation
// TODO: WRITE TESTS FOR THIS
@MainActor
final class AddEditLinkViewModel: ObservableObject {
    @Published var linkPlatform = LinkPlatform.instagram
    @Published var enteredText = ""
    
    var link: PlatformLink?
    let band: Band
    var linkUrl = ""
    
    init(link: PlatformLink?, band: Band) {
        self.band = band
        
        if let link {
            self.linkPlatform = link.platformNameAsPlatformLinkObject
            self.linkUrl = link.url
            self.link = link
        }
    }
    
    func createLink() {
        switch linkPlatform {
        case .spotify, .appleMusic:
            linkUrl = enteredText
        case .instagram:
            linkUrl = linkPlatform.urlPrefix + enteredText.lowercased()
        case .facebook:
            linkUrl = linkPlatform.urlPrefix + enteredText.lowercased() + "/posts/?ref=page_internal"
        case .none:
            break
        }
    }
    
    func uploadBandLink() throws {
        let newLink = PlatformLink(platformName: linkPlatform.rawValue, url: linkUrl)

        try DatabaseService.shared.uploadBandLink(withLink: newLink, forBand: band)
    }
}
