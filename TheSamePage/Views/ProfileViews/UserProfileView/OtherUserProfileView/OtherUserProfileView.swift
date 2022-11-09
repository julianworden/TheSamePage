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
    @State private var sendBandInviteViewIsShowing = false
    
    init(user: User?, bandMember: BandMember?) {
        _viewModel = StateObject(wrappedValue: OtherUserProfileViewModel(user: user, bandMember: bandMember))
    }
    
    var body: some View {
        if viewModel.user != nil {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl ?? ""), loadedImage: .constant(nil))
                        
                        HStack {
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
                        .buttonStyle(.bordered)
                        
                        
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
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(viewModel.user!.profileBelongsToLoggedInUser ? .large : .inline)
            .sheet(isPresented: $sendBandInviteViewIsShowing) {
                // Force unwrap is safe because the button that shows this sheet is already checking if user is nil
                NavigationView {
                    SendBandInviteView(user: viewModel.user!)
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        OtherUserProfileView(user: User.example, bandMember: BandMember.example)
    }
}
