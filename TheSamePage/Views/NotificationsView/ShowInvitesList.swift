//
//  ShowInvitesList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/6/22.
//

import SwiftUI

struct ShowInvitesList: View {
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.fetchedShowInvites) { invite in
                NotificationRow(bandInvite: nil, showInvite: invite)
                    .padding(.top, 5)
            }
        }
        .animation(.easeInOut, value: viewModel.fetchedShowInvites)
    }
}

struct ShowInvitesList_Previews: PreviewProvider {
    static var previews: some View {
        ShowInvitesList(viewModel: NotificationsViewModel())
    }
}
