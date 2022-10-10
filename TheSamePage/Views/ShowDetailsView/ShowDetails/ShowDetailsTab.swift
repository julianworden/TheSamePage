//
//  ShowDetailsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowDetailsTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        SectionTitle(title: "Details")
            .padding(.vertical)
        
        ShowDetailsList(viewModel: viewModel)
    }
}

struct ShowDetailsTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsTab(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
