//
//  BandProfileAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

struct BandProfileAdminView: View {
    @StateObject var viewModel: BandProfileViewModel
    
    @Binding var linkCreationSheetIsShowing: Bool
    
    init(band: Band, linkCreationSheetIsShowing: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band))
        _linkCreationSheetIsShowing = Binding(projectedValue: linkCreationSheetIsShowing)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            BandProfileHeader(band: viewModel.band)
            
            HStack {
                SectionTitle(title: "Members")
                
                NavigationLink {
                    MemberSearchView(userIsOnboarding: .constant(false), band: viewModel.band)
                        .navigationTitle("Search for User Profile")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .padding(.trailing)
            }
            
            if !viewModel.bandMembers.isEmpty {
                BandMemberList(bandMembers: viewModel.bandMembers, band: viewModel.band)
            } else {
                VStack {
                    Text("This band doesn't have any members.")
                        .italic()
                    
                    NavigationLink {
                        MemberSearchView(userIsOnboarding: .constant(false), band: viewModel.band)
                            .navigationTitle("Search for User Profile")
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Text("Tap here to find your band members and invite them to join the band.")
                            .italic()
                    }
                }
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            }
            
            HStack {
                SectionTitle(title: "Links")
                
                Button {
                    linkCreationSheetIsShowing = true
                } label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .padding(.trailing)
                
            }
            
            if !viewModel.bandLinks.isEmpty {
                BandLinkList(bandLinks: viewModel.bandLinks)
            } else {
                VStack {
                    Text("This band doesn't have any links")
                        .italic()
                    
                    Button {
                        linkCreationSheetIsShowing = true
                    } label: {
                        Text("Tap here to add links that will make your band easier to follow")
                            .italic()
                    }
                }
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileAdminView(band: Band.example, linkCreationSheetIsShowing: .constant(false))
    }
}
