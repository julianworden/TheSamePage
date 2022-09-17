//
//  MyShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct MyShowsView: View {
    @EnvironmentObject var showsViewModel: ShowsViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SectionTitle(title: "You're Playing")
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            ForEach(showsViewModel.yourShows) { show in
                                MyShowsShowCard(show: show)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    HStack {
                        SectionTitle(title: "You're Hosting")
                        
                        Button {
                            // TODO: Create a show
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                        }
                        .padding(.trailing)
                    }
                    
                    VStack {
                        Text("You're not hosting any shows.")
                            .font(.body.italic())
                        
                        Button {
                            // TODO: Create a show
                        } label: {
                            Text("Tap here to create a show.")
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .navigationTitle("My Shows")
                .onAppear {
                    showsViewModel.getShows()
                }
            }
        }
    }
}

struct MyShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsView()
            .environmentObject(ShowsViewModel())
    }
}
