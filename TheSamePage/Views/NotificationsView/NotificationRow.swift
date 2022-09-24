//
//  NotificationRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import SwiftUI

struct NotificationRow: View {
    @StateObject var viewModel: NotificationRowViewModel
    
    init(notification: BandInvite) {
        _viewModel = StateObject(wrappedValue: NotificationRowViewModel(notification: notification))
    }
    
    var body: some View {
        VStack {
            Text("\(viewModel.notificationSender) is inviting you to join \(viewModel.notificationBand)")
            HStack {
                Button("Accept") {
                    do {
                        try viewModel.acceptBandinvite()
                    } catch {
                        print(error)
                    }
                }
                
                Button("Decline") {
                    // TODO: Decline invitation
                }
            }
            .buttonStyle(.bordered)
        }
    }
}

struct NotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRow(notification: BandInvite.example)
    }
}
