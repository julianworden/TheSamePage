//
//  MyShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct MyShowsRootView: View {
    @StateObject var viewModel = MyShowsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColor()
                
                VStack {
                    Picker("Select Show Type", selection: $viewModel.selectedShowType) {
                        ForEach(ShowType.allCases) { showType in
                            Text(showType.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if viewModel.selectedShowType == .hosting {
                        MyHostedShowsView(viewModel: viewModel)
                    }
                    
                    if viewModel.selectedShowType == .playing {
                        MyPlayingShowsView(viewModel: viewModel)
                    }
                    
                    Spacer()
                }
            }
            .navigationViewStyle(.stack)

            .navigationTitle("My Shows")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddEditShowView(showToEdit: nil)
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
            }
        }
        // If this isn't here, AddEditShowAddressView doesn't show the search bar
        .navigationViewStyle(.stack)
    }
}

struct MyShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsRootView()
    }
}
