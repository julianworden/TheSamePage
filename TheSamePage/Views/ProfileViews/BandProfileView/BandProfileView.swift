//
//  BandProfileAdminView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/2/22.
//

import SwiftUI

// TODO: Allow for the band admin to add their own bands to any of their hosted shows

struct BandProfileView: View {
    @StateObject var viewModel: BandProfileViewModel

    @State private var linkCreationSheetIsShowing = false

    init(band: Band? = nil, showParticipant: ShowParticipant? = nil) {
        _viewModel = StateObject(wrappedValue: BandProfileViewModel(band: band, showParticipant: showParticipant))
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            if let band = viewModel.band {
                VStack(spacing: 15) {
                    BandProfileHeader(viewModel: viewModel)

                    HStack {
                        SectionTitle(title: "Members")

                        if band.loggedInUserIsBandAdmin {
                            NavigationLink {
                                MemberSearchView(userIsOnboarding: .constant(false), band: band)
                                    .navigationTitle("Search for User Profile")
                                    .navigationBarTitleDisplayMode(.inline)
                            } label: {
                                Image(systemName: "plus")
                                    .imageScale(.large)
                            }
                            .padding(.trailing)
                        }
                    }

                    if !viewModel.bandMembers.isEmpty {
                        BandMemberList(viewModel: viewModel)
                    } else {
                        VStack {
                            Text("This band doesn't have any members.")
                                .italic()

                            if band.loggedInUserIsBandAdmin {
                                NavigationLink {
                                    MemberSearchView(userIsOnboarding: .constant(false), band: band)
                                        .navigationTitle("Search for User Profile")
                                        .navigationBarTitleDisplayMode(.inline)
                                } label: {
                                    Text("Tap here to find your band members and invite them to join the band.")
                                        .italic()
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .multilineTextAlignment(.center)
                    }

                    HStack {
                        SectionTitle(title: "Links")

                        if band.loggedInUserIsBandAdmin {
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
                        BandLinkList(viewModel: viewModel)
                    } else {
                        VStack {
                            Text("This band doesn't have any links")
                                .italic()

                            if band.loggedInUserIsBandAdmin {
                                Button {
                                    linkCreationSheetIsShowing = true
                                } label: {
                                    Text("Tap here to add links that will make your band easier to follow")
                                        .italic()
                                }
                            }
                        }
                        .padding([.leading, .trailing])
                        .multilineTextAlignment(.center)
                    }

                    Spacer()
                }
            }
        }
        .navigationTitle("Band Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $linkCreationSheetIsShowing) {
            NavigationView {
                AddEditLinkView(link: nil, band: viewModel.band!)
            }
        }
    }
}

struct BandProfileAdminView_Previews: PreviewProvider {
    static var previews: some View {
        BandProfileView(band: Band.example)
    }
}
