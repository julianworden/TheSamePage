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
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(showsController.nearbyShows) { show in
                            LargeListRow(show: show, joinedShow: nil)
                        }
                    }
                }
            }
            .navigationTitle("Shows Near You")
            .onAppear {
                LocationController.shared.startLocationServices()	
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
