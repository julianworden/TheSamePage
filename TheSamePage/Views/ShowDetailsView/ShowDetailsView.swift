//
//  ShowDetailsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/19/22.
//

import SwiftUI

struct ShowDetailsView: View {
    @StateObject var viewModel: ShowDetailsViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: ShowDetailsViewModel(show: show))
    }
    
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
                        Text("\(viewModel.show.formattedDate) | Doors at \(viewModel.show.formattedDoorsTime)")
                            .font(.title2)
                    }
                    
                    // TODO: Replace icons with icons8 icons to avoid iOS 15 restrictions
                    HStack(spacing: 25) {
                        Image(systemName: "21.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 22)
                        
                        Image(systemName: "fork.knife.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 22)
                        
                        Image(systemName: "wineglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 22)
                    }
                    .padding(.top, 5)
                    
                    Text(viewModel.show.description ?? "")
                        .padding(.top, 3)
                        .padding(.horizontal)
                    
                    // TODO: Make this say something other than "Apply Now"
                    // TODO: Make this a reusable button
                    Button("Apply Now") {
                        // TODO: Send application
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .padding(.top, 10)
                    
                    // TODO: Design bill section that shows who's on the bill in a nice layout
                    
                    SectionTitle(title: "Details")
                        .padding([.vertical, .leading])
                    
                    // TODO: Make details dynamic
                    HStack(spacing: 30) {
                        VStack(spacing: 20) {
                            Text("2 out of 4 bands booked so far: Pathetic Fallacy and Dumpweed")
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
        .navigationTitle("Show Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// TODO: Figure out why this preview crashes
struct ShowDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowDetailsView(show: Show.example)
                .navigationTitle("Show Details")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
