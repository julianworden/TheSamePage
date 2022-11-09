//
//  BandShowsTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 11/8/22.
//

import SwiftUI

struct BandShowsTab: View {
    @ObservedObject var viewModel: BandProfileViewModel
    
    var body: some View {        
        if !viewModel.bandShows.isEmpty {
            BandShowsList(viewModel: viewModel)
                .padding(.top, 5)
        } else {
            VStack {
                Text("This band has never played any shows on The Same Page")
                    .italic()
            }
            .padding([.horizontal, .top])
            .multilineTextAlignment(.center)
        }
        
    }
}

struct BandShowsTab_Previews: PreviewProvider {
    static var previews: some View {
        BandShowsTab(viewModel: BandProfileViewModel(band: Band.example))
    }
}
