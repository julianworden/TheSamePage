//
//  DynamicLinkController.swift
//  TheSamePage
//
//  Created by Julian Worden on 2/19/23.
//

import FirebaseDynamicLinks
import Foundation

struct DynamicLinkController {
    static let shared = DynamicLinkController()

    func createDynamicLink(ofType dynamicLinkType: DynamicLinkType, for shareable: any Shareable) async -> URL? {
        var components = URLComponents()
        let showIdQueryItem = URLQueryItem(name: dynamicLinkType.queryItemName, value: shareable.id)
        components.scheme = DynamicLinkConstants.https
        components.host = DynamicLinkConstants.jmtWebsiteHost
        components.path = DynamicLinkConstants.dynamicLinksEndpoint
        components.queryItems = [showIdQueryItem]

        guard let linkParameter = components.url else {
            print("Error: Failed to compose URL from URLComponents object.")
            return nil

        }

        print("The link in the link parameter is: \(linkParameter)")

        guard let shareLink = DynamicLinkComponents(link: linkParameter, domainURIPrefix: DynamicLinkConstants.domainUriPrefix) else {
            print("Failed to generate DynamicLinkComponents object.")
            return nil
        }

        if let bundleId = Bundle.main.bundleIdentifier {
            shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        }

        shareLink.iOSParameters?.appStoreID = DynamicLinkConstants.appStoreId
        shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        shareLink.socialMetaTagParameters?.title = "\(shareable.name) on The Same Page"
        shareLink.socialMetaTagParameters?.descriptionText = "Tap the button below to open the app! If you don't have The Same Page installed, you'll be redirected to its page on The App Store."
        shareLink.socialMetaTagParameters?.imageURL = URL(string: DynamicLinkConstants.previewImageUrl)

        guard let longUrl = shareLink.url else {
            print("Failed to find dynamic link URL parameter.")
            return nil
        }

        print("The long dynamic link is: \(longUrl)")

        return await shortenUrl(shareLink)
    }

    func shortenUrl(_ url: DynamicLinkComponents) async -> URL? {
        do {
            let (shortenedUrl, warnings) = try await url.shorten()
            for warning in warnings {
                print("Dynamic Link Warning: \(warning)")
            }

            print("Shortened URL: \(shortenedUrl.absoluteString)")

            return shortenedUrl
        } catch {
            print("Failed to shorten URL. Error: \(error.localizedDescription)")
            return nil
        }
    }
}
