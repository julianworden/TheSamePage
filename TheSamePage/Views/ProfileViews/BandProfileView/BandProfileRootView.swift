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
    
    init(band: Band?, showParticipant: ShowParticipant?) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.band != nil {
                if viewModel.band!.loggedInUserIsBandAdmin {
                    ScrollView {
                        BandProfileAdminView(
                            viewModel: viewModel,
                            linkCreationSheetIsShowing: $linkCreationSheetIsShowing
                        )
                        .sheet(isPresented: $linkCreationSheetIsShowing) {
                            NavigationView {
                                AddEditLinkView(link: nil, band: viewModel.band!)
                            }
                        }
                    }
                } else {
                    ScrollView {
                        BandProfileOtherUserView(
                            viewModel: viewModel
                        )
                    }
                }
            }
        }
    }
}

struct BandProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BandProfileRootView(band: Band.example, showParticipant: nil)
        }
    }
}
