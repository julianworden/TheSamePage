//
//  BandMembersTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandMembersTab: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {
        if let band = viewModel.band {
            HStack {
                Spacer()
                
                if band.loggedInUserIsBandAdmin {
                    NavigationLink {
                        MemberSearchView(userIsOnboarding: .constant(false), band: band)
                            .navigationTitle("Search for User Profile")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)
            
            if !viewModel.bandMembers.isEmpty {
                BandMemberList(viewModel: viewModel)
            } else {
                VStack(spacing: 3) {
                    Text("This band doesn't have any members.")
                        .italic()
                    
                    if band.loggedInUserIsBandAdmin {
                        Text("Tap the plus button to find your band members and invite them to join the band.")
                            .italic()
                    }
                }
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            }
        }
    }
}

struct BandMembersTab_Previews: PreviewProvider {
    static var previews: some View {
        BandMembersTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
