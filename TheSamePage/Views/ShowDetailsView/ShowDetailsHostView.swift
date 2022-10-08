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
            ShowDetailsHeader(viewModel: viewModel)
            
            Text(viewModel.showDescription)
                .padding(.top, 3)
                .padding(.horizontal)
            
            // TODO: Design lineup section that shows who's on the bill in a nice layout
            
            HStack {
                SectionTitle(title: "Lineup (\(viewModel.showLineupSummary))")
                    .padding([.vertical, .leading])
                
                NavigationLink {
                    BandSearchView()
                } label: {
                    Image(systemName: "plus")
                }
                .padding(.trailing)
            }
            
            ShowLineupList(viewModel: viewModel)
            
            SectionTitle(title: "Details")
                .padding([.vertical, .leading])
            
            // TODO: Add DetailsList
            HStack(spacing: 30) {
                VStack(spacing: 20) {
                    Text("Ticket Price: $15")
                    Text("Food is being served")
                }
                .padding(.horizontal)
                
                VStack(spacing: 20) {
                    Text("Hosted by \(viewModel.showHost)")
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

struct ShowDetailsHostView_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsHostView(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
