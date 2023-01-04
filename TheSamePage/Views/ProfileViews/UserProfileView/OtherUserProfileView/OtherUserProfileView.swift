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
    
    init(user: User?, bandMember: BandMember? = nil) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, bandMember: bandMember))
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
                        
                        if !viewModel.bands.isEmpty {
                            HStack {
                                SectionTitle(title: "Member of")
                                
                                NavigationLink {
                                    AddEditBandView()
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .padding(.trailing)
                            }
                            
                            OtherUserBandList(viewModel: viewModel)
                        }
                    }
                    .navigationTitle(user.username)
                    .navigationBarTitleDisplayMode(.inline)
                }
                
            case .error:
                EmptyView()
                
            default:
                ErrorMessage(message: "Invalid viewState")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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
        NavigationView {
            OtherUserProfileView(user: User.example)
        }
    }
}
