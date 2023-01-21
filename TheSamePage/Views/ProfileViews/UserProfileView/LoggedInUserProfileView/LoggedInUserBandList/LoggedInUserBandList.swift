//
//  LoggedInUserBandList.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/9/22.
//

import SwiftUI

struct LoggedInUserBandList: View {
    @EnvironmentObject var loggedInUserController: LoggedInUserController

    @State private var bandProfileViewIsShowing = false
    
    var body: some View {
        VStack(spacing: UiConstants.listRowSpacing) {
            ForEach(Array(loggedInUserController.bands.enumerated()), id: \.element) { index, band in
                Button {
                    bandProfileViewIsShowing.toggle()
                } label: {
                    LoggedInUserBandRow(index: index)
                }
                .tint(.primary)
                .padding(.horizontal)
                .fullScreenCover(isPresented: $bandProfileViewIsShowing) {
                    NavigationView {
                        BandProfileView(band: band, isPresentedModally: true)
                    }
                }
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
