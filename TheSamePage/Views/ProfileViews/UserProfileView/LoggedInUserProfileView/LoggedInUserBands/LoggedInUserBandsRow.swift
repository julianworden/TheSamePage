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
        if loggedInUserController.allBands.indices.contains(index) {
            let band = loggedInUserController.allBands[index]
            
            ListRowElements(
                title: band.name,
                subtitle: "\(band.city), \(band.state)",
                iconName: "person.3",
                iconIsSfSymbol: true
            )
        }
    }
}

struct LoggedInUserBandRow_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandRow(index: 0)
    }
}
