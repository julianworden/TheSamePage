//
//  OtherUserProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct OtherUserProfileView: View {
    @StateObject var viewModel: UserProfileRootViewModel
    
    @State private var sendBandInviteViewIsShowing = false
    
    init(user: User?, bandMember: BandMember?) {
        _viewModel = StateObject(wrappedValue: UserProfileRootViewModel(user: user, bandMember: bandMember))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    if viewModel.profileImageUrl != nil  {
                        ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl!))
                    } else {
                        NoImageView()
                            .padding(.horizontal)
                    }
                    
                    HStack {
                        if viewModel.user != nil {
                            Button {
                                sendBandInviteViewIsShowing = true
                            } label: {
                                HStack {
                                    Image(systemName: "envelope")
                                    Text("Invite to Band")
                                }
                            }
                            
                            NavigationLink {
                                EmptyView()
                            } label: {
                                HStack {
                                    Image(systemName: "message")
                                    Text("Chat")
                                }
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    if let bands = viewModel.bands {
                        SectionTitle(title: "Member of")
                        UserBandList(bands: bands)
                    }
                }
            }
        }
        .navigationTitle("\(viewModel.firstName ?? "User Profile") \(viewModel.lastName ?? "")")
        .sheet(isPresented: $sendBandInviteViewIsShowing) {
            // Force unwrap is safe because the button that shows this sheet is already checking if user is nil
            NavigationView {
                SendBandInviteView(user: viewModel.user!)
            }
        }
    }
}

struct OtherUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(user: User.example, bandMember: BandMember.example)
    }
}
