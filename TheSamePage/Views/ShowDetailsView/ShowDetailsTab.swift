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
        let show = viewModel.show
        
        VStack(spacing: 8) {
            ShowDetailsList(viewModel: viewModel)
            
            HStack(alignment: .top, spacing: 10) {
                Image("notepad")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                if let showDescription = show.description {
                    Text(showDescription)
                        .padding(.bottom, 5)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.top, 2)
        .onDisappear {
            viewModel.removeShowListener()
        }
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
