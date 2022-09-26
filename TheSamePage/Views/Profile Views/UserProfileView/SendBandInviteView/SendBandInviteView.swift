//
//  SendBandInviteView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/25/22.
//

import SwiftUI

struct SendBandInviteView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: SendBandInviteViewModel
    
    init(user: User, band: Band?) {
        _viewModel = StateObject(wrappedValue: SendBandInviteViewModel(user: user, band: band))
    }
    
    var body: some View {
        Form {
            Picker("What role will \(viewModel.user.firstName) have?", selection: $viewModel.receipientRole) {
                ForEach(Instrument.allCases) { instrument in
                    Text(instrument.rawValue)
                }
            }
            
            Button("Send invite") {
                do {
                    try viewModel.sendBandInviteNotification()
                    dismiss()
                } catch {
                    print(error)
                }
            }
        }
        .navigationTitle("Band Invite")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SendBandInviteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendBandInviteView(user: User.example, band: Band.example)
        }
    }
}
