//
//  BandProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import SwiftUI

struct BandProfileView: View {
    @EnvironmentObject var userController: UserController
    @StateObject var viewModel: BandProfileViewModel
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            SectionTitle(title: viewModel.bandName)
            
            if viewModel.bandProfileImageUrl != nil {
                ProfileAsyncImage(url: URL(string: viewModel.bandProfileImageUrl!))
            } else {
                NoImageView()
                    .padding(.horizontal)
            }
            
            Text(viewModel.bandGenre)
            
            if let bandBio = viewModel.bandBio {
                Text(bandBio)
                    .padding(.horizontal)
            }
            HStack {
                SectionTitle(title: "Members")
                
                if viewModel.loggedInUserIsBandAdmin {
                    Button {
                        viewModel.memberSearchSheetIsShowing = true
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                }
            }
            
            if !viewModel.bandMembersAsUsers.isEmpty {
                Text(viewModel.bandMembersAsUsers.first!.firstName)
            } else {
                VStack {
                    Text("Your band doesn't have any members.")
                        .font(.body.italic())
                    
                    if viewModel.loggedInUserIsBandAdmin {
                        Button {
                            viewModel.memberSearchSheetIsShowing = true
                        } label: {
                            Text("Tap here to find your band members and invite them to join the band.")
                        }
                    } else {
                        Text("You are not the band admin. Only your band's admin is able to invite other members.")
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.memberSearchSheetIsShowing) {
            NavigationView {
                MemberSearchView(userIsOnboarding: .constant(false), band: viewModel.band)
                    .navigationTitle("Search for User Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

struct BandProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandProfileView(band: Band.example)
                .environmentObject(UserController())
        }
    }
}
