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
            HStack {
                Text(viewModel.showDescription)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding(.horizontal)
            
            ShowDetailsList(viewModel: viewModel)
        }
        .padding(.top, 2)
    }
}

struct ShowDetailsTab_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            ShowDetailsTab(viewModel: ShowDetailsViewModel(show: Show.example))
        }
    }
}
