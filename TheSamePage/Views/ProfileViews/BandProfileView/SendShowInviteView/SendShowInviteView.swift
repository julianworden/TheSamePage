//
//  SendShowInviteView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import SwiftUI

struct SendShowInviteView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: SendShowInviteViewModel
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: SendShowInviteViewModel(band: band))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .foundResults:
                Form {
                    Picker("Which show would you like to invite \(viewModel.bandName) to?", selection: $viewModel.selectedShow) {
                        ForEach(viewModel.userShows) { show in
                            Text(show.name).tag(show as Show?)
                        }
                    }
                    
                    Button("Send invite") {
                        do {
                            try viewModel.sendShowInviteNotification()
                            dismiss()
                        } catch {
                            print(error)
                        }
                    }
                }
            case .foundNoResults:
                Text("You are not hosting any shows. You must be a show admin to invite bands to play. You can create a show in the My Shows tab.")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("Send Show Invite")
        .navigationBarTitleDisplayMode(.inline)
        
        .task {
            do {
                try await viewModel.getHostedShows()
            } catch {
                print(error)
            }
        }
    }
}

struct SendShowInviteView_Previews: PreviewProvider {
    static var previews: some View {
        SendShowInviteView(band: Band.example)
    }
}
