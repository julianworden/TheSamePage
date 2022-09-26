//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var showsController: ShowsController
    
    var body: some View {
        NavigationView {
            VStack {
                SectionTitle(title: "Shows near you")
                    .padding(.top)
                
                ScrollView {
                    ForEach(showsController.nearbyShows) { show in
                        HomeShowCard(show: show)
                    }
                    .padding(.top, 5)
                }
            }
            .navigationTitle("Home")
            .onAppear {
                showsController.getShows()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(ShowsController())
    }
}
