//
//  LoggedInUserBandList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserBandList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(loggedInUserController.bands.enumerated()), id: \.element) { index, band in
                NavigationLink {
                    BandProfileView(band: band)
                    // Necessary because the view will assume .large and then shift the view awkwardly otherwise
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    LoggedInUserBandRow(index: index)
                }
                .tint(.primary)
                .padding(.horizontal)
            }
            .animation(.easeInOut, value: loggedInUserController.bands)
        }
    }
}

struct LoggedInUserBandList_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandList()
    }
}
