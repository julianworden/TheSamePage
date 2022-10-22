//
//  ShowBacklineTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowBacklineTab: View {
    @StateObject var viewModel: ShowBacklineTabViewModel
    
    @State private var addBacklineSheetIsShowing = false
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowBacklineTabViewModel(show: show))
    }
    
    var body: some View {
        VStack {
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
                .padding()
                
                if !viewModel.drumKitBacklineItems.isEmpty {
                    PercussionBacklineList(viewModel: viewModel)
                } else {
                    Text("No percussion gear is backlined for this show. You can use the plus button to add some!")
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding([.horizontal, .bottom])
                }
            }
            
            HStack {
                Text("Electric Guitar")
                    .font(.title3.bold())
                    .padding()
                
                Spacer()
            }
            
            if !viewModel.electricGuitarBacklineItems.isEmpty {
                ElectricGuitarBacklineList(viewModel: viewModel)
            } else {
                Text("No electric guitar gear is backlined for this show. You can use the plus button to add some!")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding([.horizontal, .bottom])
            }
            
            HStack {
                Text("Bass Guitar")
                    .font(.title3.bold())
                    .padding()
                
                Spacer()
            }
            
            if !viewModel.bassGuitarBacklineItems.isEmpty {
                BassGuitarBacklineList(viewModel: viewModel)
            } else {
                Text("No bass guitar gear is backlined for this show. You can use the plus button to add some!")
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding([.horizontal, .bottom])
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
        ShowBacklineTab(show: Show.example)
    }
}
