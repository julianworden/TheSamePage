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
            ForEach(Array(loggedInUserController.playingBands.enumerated()), id: \.element) { index, band in
                NavigationLink {
                    BandProfileView(band: band)
                } label: {
                    LoggedInUserBandRow(index: index)
                }
                .tint(.primary)
            }

            Divider()
        }
        .padding(.horizontal)
    }
}

struct LoggedInUserBandList_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandList()
    }
}
