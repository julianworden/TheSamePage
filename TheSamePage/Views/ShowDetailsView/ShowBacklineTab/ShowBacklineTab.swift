//
//  ShowBacklineTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowBacklineTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    @State private var addBacklineSheetIsShowing = false
    
    var body: some View {
        VStack(spacing: 15) {
            if viewModel.show.loggedInUserIsInvolvedInShow {
                HStack {
                    Text("Percussion")
                        .font(.title3.bold())
                    
                    Spacer()
                    Button {
                        addBacklineSheetIsShowing = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .padding(.horizontal)
                
                if !viewModel.drumKitBacklineItems.isEmpty || !viewModel.percussionBacklineItems.isEmpty {
                    PercussionBacklineList(viewModel: viewModel)
                } else {
                    Text("No percussion gear is backlined for this show. You can use the plus button to add some!")
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            HStack {
                Text("Electric Guitar")
                    .font(.title3.bold())
                    .padding(.horizontal)
                
                Spacer()
            }
            
            if !viewModel.electricGuitarBacklineItems.isEmpty {
                ElectricGuitarBacklineList(viewModel: viewModel)
            } else {
                Text("No electric guitar gear is backlined for this show. You can use the plus button to add some!")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            HStack {
                Text("Bass Guitar")
                    .font(.title3.bold())
                    .padding(.horizontal)
                
                Spacer()
            }
            
            if !viewModel.bassGuitarBacklineItems.isEmpty {
                BassGuitarBacklineList(viewModel: viewModel)
            } else {
                Text("No bass guitar gear is backlined for this show. You can use the plus button to add some!")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .sheet(isPresented: $addBacklineSheetIsShowing) {
            NavigationView {
                AddBacklineView(show: viewModel.show)
            }
        }
        .task {
            await viewModel.getBacklineItems(forShow: viewModel.show)
        }
        .onDisappear {
            viewModel.removeShowBacklineListener()
        }
    }
}

struct ShowBacklineTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowBacklineTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
