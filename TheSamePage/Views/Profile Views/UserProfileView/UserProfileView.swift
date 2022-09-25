//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject var viewModel: UserProfileViewModel
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(user: User?, band: Band?) {
        _viewModel = StateObject(wrappedValue: UserProfileViewModel(user: user, band: band))
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
                        
                        if viewModel.user != nil && viewModel.user?.id != nil {
                            Button("Invite to your band") {
                                Task {
                                    do {
                                        try viewModel.sendBandInviteNotification()
                                    } catch {
                                        print(error)
                                    }
                                }
                            }
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
                    
                    if viewModel.user != nil && viewModel.user?.id != nil {
                        Button("Invite to your band") {
                            Task {
                                do {
                                    try viewModel.sendBandInviteNotification()
                                } catch {
                                    print(error)
                                }
                            }
                        }
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
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(user: User.example, band: Band.example)
    }
}
