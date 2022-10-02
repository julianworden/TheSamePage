//
//  BandProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/24/22.
//

import SwiftUI

struct BandProfileRootView: View {
    @StateObject var viewModel: BandProfileViewModel
    
    @State private var memberSearchSheetIsShowing = false
    @State private var linkCreationSheetIsShowing = false
    
    let columns = [GridItem(.fixed(149), spacing: 15), GridItem(.fixed(149), spacing: 15)]
    
    init(band: Band) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band))
    }
    
    var body: some View {
        if viewModel.band.loggedInUserIsBandAdmin {
            BandProfileAdminView(
                band: viewModel.band,
                memberSearchSheetIsShowing: $memberSearchSheetIsShowing,
                linkCreationSheetIsShowing: $linkCreationSheetIsShowing
            )
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
        } else {
            BandProfileOtherUserView(
                band: viewModel.band
            )
        }
    }
}

struct BandProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandProfileRootView(band: Band.example)
        }
    }
}
