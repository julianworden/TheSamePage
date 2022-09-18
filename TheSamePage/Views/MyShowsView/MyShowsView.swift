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
                    
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack {
                            ForEach(showsController.yourShows) { show in
                                MyShowsShowCard(show: show)
                            }
                        }
                        .padding(.horizontal)
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
                    
                    Spacer()
                }
                .navigationTitle("My Shows")
                .onAppear {
                    showsController.getShows()
                }
                .sheet(isPresented: $addEditShowViewIsShowing) {
                    AddEditShowView(viewTitleText: "Create Show", addEditShowViewIsShowing: $addEditShowViewIsShowing)
                }
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
