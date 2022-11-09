//
//  LinkTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct LinkTab: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    @State private var linkCreationSheetIsShowing = false
    
    var body: some View {
        if let band = viewModel.band {
            VStack {
                HStack {
                    Spacer()
                    
                    if band.loggedInUserIsBandAdmin {
                        Button {
                            linkCreationSheetIsShowing = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 5)
                
                if !viewModel.bandLinks.isEmpty {
                    BandLinkList(viewModel: viewModel)
                } else {
                    VStack(spacing: 3) {
                        Text("This band doesn't have any links")
                            .italic()
                        
                        if band.loggedInUserIsBandAdmin {
                            Text("Tap the plus button to add links that will make your band easier to follow")
                                .italic()
                        }
                    }
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                }
            }
            .sheet(isPresented: $linkCreationSheetIsShowing) {
                NavigationView {
                    AddEditLinkView(link: nil, band: viewModel.band!)
                }
            }
        }
    }
}

struct LinkTab_Previews: PreviewProvider {
    static var previews: some View {
        LinkTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
