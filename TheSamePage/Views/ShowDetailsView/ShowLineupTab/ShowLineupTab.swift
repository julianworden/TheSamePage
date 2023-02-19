//
//  ShowLineupTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowLineupTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        if let show = viewModel.show {
            VStack {
                if !viewModel.showParticipants.isEmpty {
                    HStack {
                        Text(viewModel.showSlotsRemainingMessage)
                            .font(.title3.bold())

                        Spacer()
                    }
                    .padding(.top, 5)

                    ShowLineupList(viewModel: viewModel)

                    if show.loggedInUserIsShowHost && !show.lineupIsFull {
                        HStack {
                            Button {
                                viewModel.bandSearchViewIsShowing.toggle()
                            } label: {
                                Label("Invite Band", systemImage: "envelope")
                            }

                            Button {
                                viewModel.addMyBandToShowSheetIsShowing.toggle()
                            } label: {
                                Label("Add My Band", systemImage: "plus")
                            }
                            .sheet(
                                isPresented: $viewModel.addMyBandToShowSheetIsShowing,
                                onDismiss: {
                                    Task {
                                        await viewModel.getLatestShowData()
                                        await viewModel.getShowParticipants()
                                    }
                                },
                                content: {
                                    AddMyBandToShowView(show: show)
                                }
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.bandSearchViewIsShowing,
                        shouldDisplayButton: show.loggedInUserIsShowHost,
                        buttonText: "Invite Band",
                        buttonImageName: "envelope",
                        message: viewModel.noShowParticipantsText
                    )

                    if show.loggedInUserIsShowHost {
                        Button {
                            viewModel.addMyBandToShowSheetIsShowing.toggle()
                        } label: {
                            Label("Add My Band", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                        .sheet(
                            isPresented: $viewModel.addMyBandToShowSheetIsShowing,
                            onDismiss: {
                                Task {
                                    await viewModel.getLatestShowData()
                                    await viewModel.getShowParticipants()
                                }
                            },
                            content: {
                                AddMyBandToShowView(show: show)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $viewModel.bandSearchViewIsShowing) {
                NavigationStack {
                    BandSearchView(isPresentedModally: true)
                }
            }
        }
    }
}

struct ShowLineupTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
