//
//  DynamicLinkConstants.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/20/23.
//

import Foundation

struct DynamicLinkConstants {
    /// A redirect endpoint created on the julianmichaeltechnologies.com website.
    static let theSamePageEndpoint = "/thesamepage"
    static let jmtWebsiteHost = "www.julianmichaeltechnologies.com"
    static let https = "https"
    static let previewImageUrl = "https://firebasestorage.googleapis.com/v0/b/the-same-page-9c69e.appspot.com/o/AppIconForLinkPreviews.png?alt=media&token=a0073c14-2936-4f4c-b5bf-9b8a8969384e"
    static let appStoreId = "1609093404"
    static let domainUriPrefix = "https://thesamepage.page.link"
    /// A Dynamic Link created from Firebase Console that redirects the user to https://www.julianmichaeltechnologies.com/accountmodificationlandingpage
    /// if they try to open the app after verifying their email from a desktop, laptop, android phone, or tablet.
    static let accountModificationLandingPage = "https://thesamepage.page.link/accountmodificationlandingpage"
}
