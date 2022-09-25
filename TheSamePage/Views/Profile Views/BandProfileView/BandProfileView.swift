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
            
            SectionTitle(title: "Members")
            
            if !viewModel.bandMembersAsUsers.isEmpty {
                Text(viewModel.bandMembersAsUsers.first!.firstName)
            } else {
                VStack {
                    Text("You're not hosting any shows.")
                        .font(.body.italic())
                    
                    Button {
                        
                    } label: {
                        Text("Tap here to create a show.")
                    }
                }
                .padding(.top)
            }
            
            Spacer()
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
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
