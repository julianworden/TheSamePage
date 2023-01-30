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
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded, .workCompleted, .performingWork:
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
                    
                    AsyncButton {
                        _ = await viewModel.sendBandInvite()
                    } label: {
                        Text("Send Invite")
                    }
                    .disabled(viewModel.sendBandInviteButtonIsDisabled)
                }
                
            case .dataNotFound:
                NoDataFoundMessage(message: "You are not the admin of any bands. You can only invite others to join your band if you are the band admin.")
                    .padding(.horizontal)
                
            case .error:
                EmptyView()
                
            default:
                ErrorMessage(message: "Unknown viewState set: \(viewModel.viewState)")
            }
        }
        .navigationTitle("Send Band Invite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .task {
            await viewModel.getLoggedInUserBands()
        }
        .onChange(of: viewModel.bandInviteSentSuccessfully) { bandInviteSentSuccessfully in
            if bandInviteSentSuccessfully {
                dismiss()
            }
        }
    }
}

struct SendBandInviteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SendBandInviteView(user: User.example)
        }
    }
}
