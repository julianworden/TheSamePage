//
//  BandInvitesList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import SwiftUI

struct BandInvitesList: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.fetchedBandInvites) { invite in
                NotificationRow(bandInvite: invite, showInvite: nil)
                    .padding(.top, 5)
            }
        }
        .animation(.easeInOut, value: viewModel.fetchedBandInvites)
    }
}

struct BandInvitesList_Previews: PreviewProvider {
    static var previews: some View {
        BandInvitesList(viewModel: NotificationsViewModel())
    }
}
