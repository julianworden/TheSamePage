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
                ZStack {
                    VStack {
                        HStack {
                            NavigationLink {
                                BandProfileView(band: band)
                            } label: {
                                LoggedInUserBandRow(index: index)
                            }
                            .tint(.primary)

                            Spacer()

                            if band.loggedInUserIsBandMember && !band.loggedInUserIsBandAdmin {
                                LoggedInUserBandMenuButton(band: band)
                            }
                        }

                        Divider()
                    }
                }
            }
        }
        .padding(.top, 5)
    }
}

struct LoggedInUserBandList_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandList()
    }
}
