//
//  OtherUserProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct OtherUserProfileView: View {
    @StateObject var viewModel: UserProfileRootViewModel
    
    init(user: User?, band: Band?, bandMember: BandMember?) {
        _viewModel = StateObject(wrappedValue: UserProfileRootViewModel(user: user, band: band, bandMember: bandMember))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                if viewModel.profileImageUrl != nil  {
                    ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl!))
                } else {
                    NoImageView()
                        .padding(.horizontal)
                }
                
                NavigationLink {
                    if viewModel.user != nil {
                        SendBandInviteView(user: viewModel.user!, band: viewModel.band)
                    }
                } label: {
                    Text("Invite to Band")
                }
                
                if let bands = viewModel.bands {
                    SectionTitle(title: "Member of")
                    UserBandList(bands: bands)
                }
            }
        }
        .navigationTitle("\(viewModel.firstName ?? "User Profile") \(viewModel.lastName ?? "")")
    }
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(user: User.example, band: Band.example, bandMember: BandMember.example)
    }
}
