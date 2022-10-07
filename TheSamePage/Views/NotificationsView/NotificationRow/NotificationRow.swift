//
//  NotificationRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/23/22.
//

import SwiftUI

struct NotificationRow: View {
    @StateObject var viewModel: NotificationRowViewModel
    
    init(bandInvite: BandInvite?, showInvite: ShowInvite?) {
        _viewModel = StateObject(wrappedValue: NotificationRowViewModel(bandInvite: bandInvite, showInvite: showInvite))
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
                if let bandInvite = viewModel.bandInvite {
                    Text(bandInvite.inviteMessage)
                } else if let showInvite = viewModel.showInvite {
                    Text(showInvite.inviteMessage)
                }
                
                VStack {
                    Button("Accept") {
                        Task {
                            do {
                                if viewModel.bandInvite != nil {
                                    try await viewModel.acceptBandInvite()
                                } else if viewModel.showInvite != nil {
                                    try await viewModel.acceptShowInvite()
                                }
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Button("Decline") {
                        if viewModel.bandInvite != nil {
                            viewModel.declineBandInvite()
                        } else if viewModel.showInvite != nil {
                            viewModel.declineShowInvite()
                        }
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
        NotificationRow(bandInvite: BandInvite.example, showInvite: ShowInvite.example)
    }
}
