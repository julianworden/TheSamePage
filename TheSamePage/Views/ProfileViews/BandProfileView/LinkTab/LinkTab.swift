//
//  LinkTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct LinkTab: View {
    @ObservedObject var viewModel: BandProfileViewModel

    var body: some View {
        if let band = viewModel.band {
            VStack {
                HStack {
                    Spacer()
                    
                    if band.loggedInUserIsBandAdmin {
                        Button {
                            viewModel.addEditLinkSheetIsShowing.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .sheet(
                            isPresented: $viewModel.addEditLinkSheetIsShowing,
                            onDismiss: {
                                Task {
                                    await viewModel.getBandLinks()
                                }
                            },
                            content: {
                                NavigationView {
                                    AddEditLinkView(link: nil, band: viewModel.band!)
                                }
                                // Without this, the sheet looks strange when dismissed
                                .navigationViewStyle(.stack)
                            }
                        )
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
        }
    }
}

struct LinkTab_Previews: PreviewProvider {
    static var previews: some View {
        LinkTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
