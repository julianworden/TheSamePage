//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

/// Displayed when a user is viewing somebody else's profile.
struct OtherUserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel: OtherUserProfileViewModel
    
    init(user: User?, bandMember: BandMember? = nil, isPresentedModally: Bool = false) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, bandMember: bandMember, isPresentedModally: isPresentedModally))
    }
    
    var body: some View {
        ZStack {
            BackgroundColor()
            
            switch viewModel.viewState {
            case .dataLoading:
                ProgressView()
                
            case .dataLoaded:
                if let user = viewModel.user {
                    ScrollView {
                        OtherUserProfileHeader(viewModel: viewModel)
                        
                            HStack {
                                SectionTitle(title: "Member of")
                            }

                        if !viewModel.bands.isEmpty {
                            OtherUserBandList(viewModel: viewModel)
                        } else {
                            NoDataFoundMessage(message: "This user is not a member of any bands")
                                .padding(.top)
                        }
                    }
                    .navigationTitle(user.username)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.sendBandInviteViewIsShowing = true
                            } label: {
                                Image(systemName: "envelope")
                            }
                            .sheet(isPresented: $viewModel.sendBandInviteViewIsShowing) {
                                SendBandInviteView(user: user)
                            }
                        }
                    }
                }
                
            case .error:
                EmptyView()
                
            default:
                ErrorMessage(message: "Invalid viewState: \(viewModel.viewState)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.isPresentedModally {
                    Button("Back", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .errorAlert(
            isPresented: $viewModel.errorAlertIsShowing,
            message: viewModel.errorAlertText,
            okButtonAction: {
                dismiss()
            }
        )
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OtherUserProfileView(user: User.example)
        }
    }
}
