//
//  BandProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import SwiftUI

struct BandProfileView: View {
    @StateObject var viewModel: BandProfileViewModel
    
    @State private var memberSearchSheetIsShowing = false
    @State private var linkCreationSheetIsShowing = false
    
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            if viewModel.bandProfileImageUrl != nil {
                ProfileAsyncImage(url: URL(string: viewModel.bandProfileImageUrl!))
            } else {
                NoImageView()
                    .padding(.horizontal)
            }
            
            VStack {
                Text(viewModel.bandName)
                    .font(.title.bold())
                
                Text("\(viewModel.bandGenre) from \(viewModel.bandCity), \(viewModel.bandState)")
            }
            .padding(.top, 2)
            
            if let bandBio = viewModel.bandBio {
                Text(bandBio)
                    .padding(.horizontal)
            }
            
            HStack {
                SectionTitle(title: "Members")
                
                if viewModel.band.loggedInUserIsBandAdmin {
                    Button {
                        memberSearchSheetIsShowing = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                }
            }
            
            if !viewModel.bandMembers.isEmpty {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.bandMembers) { bandMember in
                        if !bandMember.bandMemberIsLoggedInUser {
                            NavigationLink {
                                UserProfileView(user: nil, band: viewModel.band, bandMember: bandMember, userIsLoggedOut: .constant(false), selectedTab: .constant(4))
                            } label: {
                                BandMemberCard(bandMember: bandMember)
                            }
                            .tint(.black)
                        } else {
                            BandMemberCard(bandMember: bandMember)
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                VStack {
                    Text("Your band doesn't have any members.")
                        .italic()
                    
                    if viewModel.band.loggedInUserIsBandAdmin {
                        Button {
                            memberSearchSheetIsShowing = true
                        } label: {
                            Text("Tap here to find your band members and invite them to join the band.")
                                .italic()
                        }
                    } else {
                        Text("You are not the band admin. Only your band's admin is able to invite other members.")
                            .italic()
                    }
                }
                .multilineTextAlignment(.center)
            }
            
            HStack {
                SectionTitle(title: "Links")
                
                if viewModel.band.loggedInUserIsBandAdmin {
                    Button {
                        linkCreationSheetIsShowing = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                }
            }
            
            if !viewModel.bandLinks.isEmpty {
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(viewModel.bandLinks) { link in
                        BandLinkCard(link: link)
                    }
                }
            }
            
            Spacer()
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $memberSearchSheetIsShowing) {
            NavigationView {
                MemberSearchView(userIsOnboarding: .constant(false), band: viewModel.band)
                    .navigationTitle("Search for User Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $linkCreationSheetIsShowing) {
            NavigationView {
                AddEditLinkView(link: nil, band: viewModel.band)
            }
        }
    }
}

struct BandProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandProfileView(band: Band.example)
        }
    }
}
