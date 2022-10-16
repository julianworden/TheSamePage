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
            case .dataLoading:
                ProgressView()
            case .dataLoaded:
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
            case .dataNotFound:
                Text("No hosted shows found. You either have no internet connection or you are not hosting any shows. You can create a show in the My Shows tab.")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            case .error(let message):
                ErrorMessage(
                    message: "Failed to fetch your hosted shows. Please check your internet connection and relaunch the app.",
                    errorText: message
                )
            }
        }
        .navigationTitle("Send Show Invite")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                try await viewModel.getHostedShows()
            } catch {
                viewModel.state = .error(message: error.localizedDescription)
            }
        }
    }
}

struct SendShowInviteView_Previews: PreviewProvider {
    static var previews: some View {
        SendShowInviteView(band: Band.example)
    }
}
