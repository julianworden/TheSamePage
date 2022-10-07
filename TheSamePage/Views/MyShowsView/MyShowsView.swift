//
//  MyShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct MyShowsView: View {
    @EnvironmentObject var showsController: ShowsController
    
    @StateObject var viewModel = MyShowsViewModel()
    
    @State var addEditShowViewIsShowing = false
    
    var body: some View {
        // TODO: Make this layout a segmented picker with You're Playing and You're Hosting
        NavigationView {
            ScrollView {
                VStack {
                    SectionTitle(title: "You're Playing")
                        .padding(.top)
                    
                    if !viewModel.playingShows.isEmpty {
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(viewModel.playingShows) { show in
                                    NavigationLink {
                                        ShowDetailsRootView(show: show)
                                    } label: {
                                        MyShowsShowCard(show: show)
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("You're not playing any shows.")
                            .font(.body.italic())
                            .padding(.vertical)
                    }
                    
                    HStack {
                        SectionTitle(title: "You're Hosting")
                        
                        Button {
                            addEditShowViewIsShowing = true
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                        }
                        .padding(.trailing)
                    }
                    
                    if !viewModel.hostedShows.isEmpty {
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(viewModel.hostedShows) { show in
                                    NavigationLink {
                                        ShowDetailsRootView(show: show)
                                    } label: {
                                        MyShowsShowCard(show: show)
                                    }
                                    .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        VStack {
                            Text("You're not hosting any shows.")
                                .font(.body.italic())
                            
                            Button {
                                addEditShowViewIsShowing = true
                            } label: {
                                Text("Tap here to create a show.")
                            }
                        }
                        .padding(.top)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("My Shows")
            .background(Color(uiColor: .systemGroupedBackground))
            .task {
                // Leaving this logic here to maintain showsController architecture
                do {
                    try await viewModel.getHostedShows()
                    try await viewModel.getPlayingShows()
                } catch {
                    print(error)
                }
            }
            .onDisappear {
                viewModel.removeShowListeners()
            }
            .sheet(isPresented: $addEditShowViewIsShowing) {
                AddEditShowView(viewTitleText: "Create Show", addEditShowViewIsShowing: $addEditShowViewIsShowing, showToEdit: nil)
            }
        }
    }
}

struct MyShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsView()
            .environmentObject(ShowsController())
    }
}
