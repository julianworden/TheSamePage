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
                    iconName: "person.3",
                    iconIsSfSymbol: true,
                    displayChevron: true
                )
            }
            
            if let user {
                // TODO: Use the person SF Symbol instead to make the app more consistent with TabView and BandProfileView
                ListRowElements(
                    title: user.profileBelongsToLoggedInUser ? "You" : user.username,
                    subtitle: user.fullName,
                    iconName: "person",
                    iconIsSfSymbol: true,
                    displayChevron: !user.profileBelongsToLoggedInUser
                )
            }
            
            if let show {
                // TODO: Use the music.note.house SF Symbol isntead to make the app more consistent with BandProfileView
                ListRowElements(
                    title: show.name,
                    subtitle: show.venue,
                    iconName: "music.note.house",
                    iconIsSfSymbol: true,
                    displayChevron: true
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
