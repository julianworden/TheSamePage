//
//  MyShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct MyShowsView: View {
    @EnvironmentObject var showsController: ShowsController
    
    @State private var addEditShowViewIsShowing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SectionTitle(title: "You're Playing")
                        .padding(.top)
                    
                    if !showsController.playingShows.isEmpty {
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(showsController.playingShows) { show in
                                    NavigationLink {
                                        ShowDetailsView(show: show)
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
                    
                    if !showsController.hostedShows.isEmpty {
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(showsController.hostedShows) { show in
                                    NavigationLink {
                                        ShowDetailsView(show: show)
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
            // TODO: Replace with .task in iOS 15
            .onAppear {
                Task {
                    do {
                        try await showsController.getHostedShows()
                        try await showsController.getPlayingShows()
                    } catch {
                        print(error)
                    }
                }
            }
            .onDisappear {
                showsController.removeShowListeners()
            }
            .sheet(isPresented: $addEditShowViewIsShowing) {
                AddEditShowView(viewTitleText: "Create Show", addEditShowViewIsShowing: $addEditShowViewIsShowing)
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
