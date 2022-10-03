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
    
    init(user: User) {
        _viewModel = StateObject(wrappedValue: SendBandInviteViewModel(user: user))
    }
    
    var body: some View {
        if !viewModel.userBands.isEmpty {
            Form {
                Picker("Which band would you like to invite \(viewModel.user.firstName) to?", selection: $viewModel.selectedBand) {
                    ForEach(viewModel.userBands) { band in
                        Text(band.name).tag(band as Band?)
                    }
                }
                .id(viewModel.selectedBand)
                
                Picker("What role will \(viewModel.user.firstName) have?", selection: $viewModel.recipientRole) {
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
        } else {
            Text("You are not the admin for any bands. You can only invite others to join your band if you are the band admin.")
                .italic()
        }
    }
}

struct SendBandInviteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SendBandInviteView(user: User.example)
        }
    }
}
