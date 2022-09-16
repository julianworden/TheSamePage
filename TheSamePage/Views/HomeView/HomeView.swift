//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var showsViewModel: ShowsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                SectionTitle(title: "Home")
                
                ScrollView {
                    ForEach(showsViewModel.shows) { show in
                        HomeShowCard(show: show)
                    }
                }
            }
            .navigationTitle("Home")
        }
        .onAppear {
            showsViewModel.getShows()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ShowsViewModel())
    }
}
