//
//  ShowDetailsHostView.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import SwiftUI

struct ShowDetailsHostView: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                Image("concertPhoto")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 232)
                
                VStack(spacing: 7) {
                    Text(viewModel.show.name)
                        .font(.title.bold())
                    
                    VStack {
                        // TODO: Stop hard coding the show address
                        Text("\(viewModel.show.venue) | Sayreville, NJ")
                            .font(.title2)
                        
                        // TODO: Make time dynamic depending on what time is soonest
                        if let showDate = viewModel.show.formattedDate,
                           let doorsTime = viewModel.show.formattedDoorsTime {
                            Text("\(showDate) | Doors at \(doorsTime)")
                                .font(.title2)
                        }
                    }
                    
                    // TODO: Replace icons with icons8 icons to avoid iOS 15 restrictions
                    Text("This show is over 21")
                        .padding(.top, 5)
                    
                    Text(viewModel.show.description ?? "")
                        .padding(.top, 3)
                        .padding(.horizontal)
                    
                    // TODO: Design lineup section that shows who's on the bill in a nice layout
                    
                    HStack {
                        SectionTitle(title: "Lineup")
                            .padding([.vertical, .leading])
                        
                        NavigationLink {
                            BandSearchView()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding(.trailing)
                    }
                    
                    SectionTitle(title: "Details")
                        .padding([.vertical, .leading])
                    
                    // TODO: Make details dynamic
                    HStack(spacing: 30) {
                        VStack(spacing: 20) {
                            Text("Ticket Price: $15")
                            Text("Food is being served")
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 20) {
                            Text("Hosted by DAA Entertainment")
                            Text("21 and over")
                            Text("Drinks are being served")
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                    
                    // TODO: Design backline section
                    SectionTitle(title: "Backline")
                        .padding([.vertical, .leading])
                }
            }
        }
    }
}

struct ShowDetailsHostView_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHostView(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
