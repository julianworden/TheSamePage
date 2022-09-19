//
//  HomeView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var showsController: ShowsController
    
    @Binding var userIsLoggedOut: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                SectionTitle(title: "Shows near you")
                    .padding(.top)
                
                ScrollView {
                    ForEach(showsController.showsNearYou) { show in
                        HomeShowCard(show: show)
                    }
                    .padding(.top, 5)
                }
            }
            .navigationTitle("Home")
            .onAppear {
                showsController.getShows()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        do {
                            try AuthController.logOut()
                            userIsLoggedOut = true
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(userIsLoggedOut: .constant(false))
            .environmentObject(ShowsController())
    }
}
