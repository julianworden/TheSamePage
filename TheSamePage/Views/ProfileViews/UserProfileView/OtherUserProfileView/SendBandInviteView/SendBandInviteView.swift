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
                
            case .dataLoaded, .workCompleted, .performingWork, .error:
                Form {
                    Picker("Which band would you like to invite \(viewModel.user.firstName) to?", selection: $viewModel.selectedBand) {
                        ForEach(viewModel.adminBands) { band in
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
                    .disabled(viewModel.buttonsAreDisabled)
                }
                .scrollDismissesKeyboard(.interactively)
                
            case .dataNotFound:
                NoDataFoundMessage(message: ErrorMessageConstants.userIsNotAdminOfAnyBands)
                    .padding(.horizontal)
                
            default:
                ErrorMessage(message: "Unknown viewState set: \(viewModel.viewState)")
            }
        }
        .navigationTitle("Send Band Invite")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(viewModel.buttonsAreDisabled)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
                .disabled(viewModel.buttonsAreDisabled)
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText
        )
        .task {
            await viewModel.getLoggedInUserAdminBands()
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
