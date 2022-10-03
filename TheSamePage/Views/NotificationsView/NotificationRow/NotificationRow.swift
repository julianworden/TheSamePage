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
    
    // TODO: Add notification timestamp
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .frame(height: 125)
            
            HStack {
                Text("\(viewModel.notificationSender) is inviting you to join \(viewModel.notificationBand)")
                
                VStack {
                    Button("Accept") {
                        Task {
                            do {
                                try await viewModel.acceptBandInvite()
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Button("Decline") {
                        viewModel.declineBandInvite()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

struct NotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationRow(notification: BandInvite.example)
    }
}
