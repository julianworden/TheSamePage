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
        VStack(spacing: 15) {
            if viewModel.showHasBackline {
                if !viewModel.drumKitBacklineItems.isEmpty || !viewModel.percussionBacklineItems.isEmpty {
                    HStack {
                        Text("Percussion")
                            .font(.title3.bold())
                        Spacer()
                    }

                    PercussionBacklineList(viewModel: viewModel)
                }

                if !viewModel.electricGuitarBacklineItems.isEmpty {
                    HStack {
                        Text("Electric Guitar")
                            .font(.title3.bold())

                        Spacer()
                    }

                    ElectricGuitarBacklineList(viewModel: viewModel)
                }

                if !viewModel.bassGuitarBacklineItems.isEmpty {
                    HStack {
                        Text("Bass Guitar")
                            .font(.title3.bold())

                        Spacer()
                    }

                    BassGuitarBacklineList(viewModel: viewModel)
                }

                Button {
                    viewModel.addBacklineSheetIsShowing.toggle()
                } label: {
                    Label("Add Backline", systemImage: "plus")
                }
                .buttonStyle(.bordered)

            } else if !viewModel.showHasBackline {
                VStack(spacing: 7) {
                    Text(viewModel.noBacklineMessageText)
                        .multilineTextAlignment(.center)

                    if viewModel.show.loggedInUserIsInvolvedInShow {
                        Button("Add Backline") {
                            viewModel.addBacklineSheetIsShowing.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(
            isPresented: $viewModel.addBacklineSheetIsShowing,
            onDismiss: {
                Task {
                    await viewModel.getBacklineItems(forShow: viewModel.show)
                }
            },
            content: {
                NavigationView {
                    AddBacklineView(show: viewModel.show)
                }
            }
        )
    }
}

struct ShowBacklineTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
