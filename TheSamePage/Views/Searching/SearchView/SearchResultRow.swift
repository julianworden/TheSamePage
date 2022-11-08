//
//  SearchResultRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI

struct SearchResultRow: View {
    let band: Band?
    let user: User?
    let show: Show?
    
    init(band: Band? = nil, user: User? = nil, show: Show? = nil) {
        self.band = band
        self.user = user
        self.show = show
    }
    
    var body: some View {
        HStack {
            if let band {
                ListRowElements(
                    title: band.name,
                    subtitle: "\(band.city), \(band.state)",
                    iconName: "band",
                    displayChevron: true,
                    displayDivider: true
                )
            }
            
            if let user {
                ListRowElements(
                    title: user.profileBelongsToLoggedInUser ? "You" : user.username,
                    subtitle: user.fullName,
                    iconName: "user",
                    displayChevron: !user.profileBelongsToLoggedInUser,
                    displayDivider: true
                )
            }
            
            if let show {
                ListRowElements(
                    title: show.name,
                    subtitle: show.venue,
                    iconName: "stage",
                    displayChevron: true,
                    displayDivider: true
                )
            }
            
            Spacer()
        }
    }
}

struct SearchResultRow_Previews: PreviewProvider {
    static var previews: some View {
        SearchResultRow(band: nil, user: nil, show: Show.example)
            .previewLayout(.fixed(width: 390, height: 44))
    }
}
