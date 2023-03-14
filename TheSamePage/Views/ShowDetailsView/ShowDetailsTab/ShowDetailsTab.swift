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
        VStack(spacing: 8) {
            ShowDetailsList(viewModel: viewModel)
        }
    }
}

struct ShowDetailsTab_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundColor()
            
            ShowDetailsTab(viewModel: ShowDetailsViewModel(show: Show.example))
        }
    }
}
