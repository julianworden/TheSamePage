//
//  LoggedInUserBandRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserBandRow: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    let index: Int
    
    var body: some View {
        let band = loggedInUserController.bands[index]
        
        ListRowElements(
            title: band.name,
            subtitle: "\(band.city), \(band.state)",
            iconName: "band",
            displayChevron: true,
            displayDivider: true
        )
    }
}

struct LoggedInUserBandRow_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandRow(index: 0)
    }
}
