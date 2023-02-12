//
//  ShowBacklineTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowBacklineTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel

    var body: some View {
        if let show = viewModel.show {
            VStack(spacing: 15) {
                if viewModel.showHasBackline {
                    ShowBacklineList(viewModel: viewModel)

                    Button {
                        viewModel.addBacklineSheetIsShowing.toggle()
                    } label: {
                        Label("Add Backline", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                    .sheet(
                        isPresented: $viewModel.addBacklineSheetIsShowing,
                        onDismiss: {
                            Task {
                                await viewModel.getBacklineItems()
                            }
                        },
                        content: {
                            AddBacklineView(show: show)
                        }
                    )

                } else if !viewModel.showHasBackline {
                    NoDataFoundMessageWithButtonView(
                        isPresentingSheet: $viewModel.addBacklineSheetIsShowing,
                        shouldDisplayButton: show.loggedInUserIsInvolvedInShow,
                        buttonText: "Add Backline",
                        buttonImageName: "plus",
                        message: viewModel.noBacklineMessageText
                    )
                    .sheet(
                        isPresented: $viewModel.addBacklineSheetIsShowing,
                        onDismiss: {
                            Task {
                                await viewModel.getBacklineItems()
                            }
                        },
                        content: {
                            AddBacklineView(show: show)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 5)
        }
    }
}

struct ShowBacklineTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
