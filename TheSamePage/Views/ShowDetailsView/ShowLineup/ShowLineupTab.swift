//
//  ShowLineupTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowLineupTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        HStack {
            SectionTitle(title: "Lineup (\(viewModel.showSlotsRemaining))")
                .padding(.vertical)
            
            NavigationLink {
                BandSearchView()
            } label: {
                Image(systemName: "plus")
            }
            .padding(.trailing)
        }
        
        ShowLineupList(viewModel: viewModel)
    }
}

struct ShowLineupTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLineupTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
