//
//  BandProfileOtherUserView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileOtherUserView: View {
    @StateObject var viewModel: BandProfileViewModel
    
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    @State private var inviteToShowSheetIsShowing = false
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band))
    }
    
    var body: some View {
        VStack(spacing: 15) {
            BandProfileHeader(band: viewModel.band)
            
            // TODO: Keep this button from showing for anybody that's in the band
            Button {
                inviteToShowSheetIsShowing = true
            } label: {
                Label("Invite to Show", systemImage: "envelope")
            }
            .buttonStyle(.bordered)
            
            
            SectionTitle(title: "Members")
            
            if !viewModel.bandMembers.isEmpty {
                BandMemberList(bandMembers: viewModel.bandMembers, band: viewModel.band)
            } else {
                VStack {
                    Text("This band doesn't have any members.")
                        .italic()
                    
                    Text("Only this band's admin is able to invite other members.")
                        .italic()
                }
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            }
            
            SectionTitle(title: "Links")
            
            if !viewModel.bandLinks.isEmpty {
                BandLinkList(bandLinks: viewModel.bandLinks)
            } else {
                VStack {
                    Text("This band doesn't have any links")
                        .italic()
                    
                    Text("Only this band's admin can add links")
                        .italic()
                }
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
        .sheet(isPresented: $inviteToShowSheetIsShowing) {
            SendShowInviteView(band: viewModel.band)
        }
    }
}

struct BandProfileOtherUserView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileOtherUserView(band: Band.example)
    }
}
