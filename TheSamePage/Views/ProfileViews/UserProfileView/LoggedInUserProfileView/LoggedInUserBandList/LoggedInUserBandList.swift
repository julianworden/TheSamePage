//
//  LoggedInUserBandList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserBandList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var selectedBand: Band?

    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(loggedInUserController.bands.enumerated()), id: \.element) { index, band in
                Button {
                    selectedBand = band
                } label: {
                    LoggedInUserBandRow(index: index)
                }
                .tint(.primary)
                .padding(.horizontal)
                .fullScreenCover(
                    item: $selectedBand,
                    onDismiss: {
                        Task {
                            await loggedInUserController.getLoggedInUserBands()
                        }
                    },
                    content: { selectedBand in
                        NavigationView {
                            BandProfileView(band: selectedBand, isPresentedModally: true)
                        }
                    }
                )
            }

            Divider()
        }
        .animation(.easeInOut, value: loggedInUserController.bands)
    }
}

struct LoggedInUserBandList_Previews: PreviewProvider {
    static var previews: some View {
        LoggedInUserBandList()
    }
}
