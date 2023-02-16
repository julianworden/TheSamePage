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
        NavigationStack {
            ZStack(alignment: .top) {
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
                }
            }
            .navigationTitle("My Shows")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.addEditShowSheetIsShowing.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .fullScreenCover(
                isPresented: $viewModel.addEditShowSheetIsShowing,
                onDismiss: {
                    Task {
                        await viewModel.getHostedShows()
                    }
                },
                content: {
                    NavigationStack {
                        AddEditShowView(showToEdit: nil, isPresentedModally: true)
                    }
                }
            )
        }
    }
}

struct MyShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsRootView()
    }
}
