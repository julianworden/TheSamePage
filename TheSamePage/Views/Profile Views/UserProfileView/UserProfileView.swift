//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject var viewModel: UserProfileViewModel
    
    @Binding var userIsLoggedOut: Bool
    @Binding var selectedTab: Int
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(user: User?, band: Band?, userIsLoggedOut: Binding<Bool>, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user, band: band))
        _userIsLoggedOut = Binding(projectedValue: userIsLoggedOut)
        _selectedTab = Binding(projectedValue: selectedTab)
    }
    
    var body: some View {
        if viewModel.user == nil {
            NavigationView {
                ScrollView {
                    VStack {
                        if viewModel.user != nil {
                            SectionTitle(title: "\(viewModel.user!.firstName) \(viewModel.user!.lastName)")
                        } else if viewModel.firstName != nil && viewModel.lastName != nil {
                            SectionTitle(title: "\(viewModel.firstName!) \(viewModel.lastName!)")
                        } else {
                            SectionTitle(title: "Your Profile")
                        }
                        
                        if viewModel.profileImageUrl != nil  {
                            ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl!))
                        } else {
                            NoImageView()
                                .padding(.horizontal)
                        }
                        
                        if let bands = viewModel.bands {
                            
                            SectionTitle(title: "Member of")
                            
                            LazyVGrid(columns: columns) {
                                ForEach(bands) { band in
                                    NavigationLink {
                                        BandProfileView(band: band)
                                    } label: {
                                        UserProfileBandCard(band: band)
                                    }
                                    .tint(.black)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .task {
                    do {
                        try await viewModel.initializeUser(user: nil)
                        try await viewModel.getBands(forUser: nil)
                    } catch {
                        print(error)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log Out") {
                            do {
                                try viewModel.logOut()
                                userIsLoggedOut = true
                                selectedTab = 0
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
            }
        } else {
            ScrollView {
                VStack {
                    if viewModel.user != nil {
                        SectionTitle(title: "\(viewModel.user!.firstName) \(viewModel.user!.lastName)")
                    } else if viewModel.firstName != nil && viewModel.lastName != nil {
                        SectionTitle(title: "\(viewModel.firstName!) \(viewModel.lastName!)")
                    } else {
                        SectionTitle(title: "Your Profile")
                    }
                    
                    if viewModel.profileImageUrl != nil  {
                        ProfileAsyncImage(url: URL(string: viewModel.profileImageUrl!))
                    } else {
                        NoImageView()
                            .padding(.horizontal)
                    }
                    
                    NavigationLink {
                        // TODO: Fix force unwrapping
                        SendBandInviteView(user: viewModel.user!, band: viewModel.band)
                    } label: {
                        Text("Invite to Band")
                    }
                    
                    if let bands = viewModel.bands {
                        
                        SectionTitle(title: "Member of")
                        
                        LazyVGrid(columns: columns) {
                            ForEach(bands) { band in
                                NavigationLink {
                                    BandProfileView(band: band)
                                } label: {
                                    UserProfileBandCard(band: band)
                                }
                                .tint(.black)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $viewModel.sendBandInviteSheetIsShowing) {
                SendBandInviteView(user: viewModel.user!, band: viewModel.band!)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: User.example, band: Band.example, userIsLoggedOut: .constant(false), selectedTab: .constant(3))
    }
}
