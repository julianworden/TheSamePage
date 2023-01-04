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
    
    @State private var alertText = ""
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: SendShowInviteViewModel(band: band))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
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
                        Task {
                            await viewModel.sendShowInviteNotification()
                            dismiss()
                        }
                    }
                }
            case .dataNotFound:
                Text("No hosted shows found. You either have no internet connection or you are not hosting any shows. You can create a show in the My Shows tab.")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            default:
                ErrorMessage(message: "Unknown ViewState provided to SendShowInviteView.")
            }
        }
        .navigationTitle("Send Show Invite")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Error",
            isPresented: $viewModel.invalidInviteAlertIsShowing,
            actions: {
                Button("OK") { }
            }, message: {
                Text(alertText)
            }
        )
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            tryAgainAction: { await viewModel.getHostedShows() }
        )
        .task {
            await viewModel.getHostedShows()
        }
    }
}

struct SendShowInviteView_Previews: PreviewProvider {
    static var previews: some View {
        SendShowInviteView(band: Band.example)
    }
}
