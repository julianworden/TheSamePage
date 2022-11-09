//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

/// Displayed when a user is viewing somebody else's profile.
struct OtherUserProfileView: View {
    @StateObject var viewModel: OtherUserProfileViewModel
    
    @State private var addEditBandSheetIsShowing = false
    
    init(user: User?, bandMember: BandMember? = nil) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, bandMember: bandMember))
    }
    
    var body: some View {
        if let user = viewModel.user {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
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
                }
            }
            .navigationTitle(user.username)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OtherUserProfileView(user: User.example)
        }
    }
}
